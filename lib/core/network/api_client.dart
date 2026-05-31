import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_exceptions.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  Future<dynamic> post({required String url, required Map<String, String> headers, required Map<String, dynamic> body}) async {
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return _returnJsonResponse(response);
    } on SocketException {
      throw FetchDataException(errorMsg: "No Internet Connection!");
    } on AppExceptions {
      rethrow;
    } catch (e) {
      throw FetchDataException(errorMsg: e.toString());
    }
  }

  dynamic _returnJsonResponse(http.Response response) {
    var responseData = jsonDecode(response.body);
    switch (response.statusCode) {
      case 200:
        if (responseData['error'] != null) {
          throw BadRequestException(errorMsg: responseData['error']['message']);
        }
        return responseData;
      case 400:
        throw BadRequestException(errorMsg: responseData['error']['message'] ?? "Invalid Request");
      case 401:
      case 403:
        throw UnauthorisedException(errorMsg: "Unauthorized: Check API Key");
      case 500:
      default:
        throw FetchDataException(errorMsg: 'Server error: ${response.statusCode}');
    }
  }


}