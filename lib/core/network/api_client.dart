import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tensai/core/constants/api_endpoints.dart';
import 'api_exceptions.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  Future<dynamic> getApi({required String url}) async {
    var uri = Uri.parse(url);
    try {
      var res = await http.get(uri);
      return _returnJsonResponse(res);
    } on SocketException catch (_) {
      throw FetchDataException(errorMsg: "No Internet!!");
    }
  }

  Future<dynamic> postApi({required String url, Map<String, dynamic>? bodyParams}) async {
    var uri = Uri.parse(url);
    try {
      var res = await http.post(uri, body: bodyParams ?? {});
      return _returnJsonResponse(res);
    } on SocketException catch (_) {
      throw FetchDataException(errorMsg: "No Internet!!");
    }
  }

  Future<dynamic> sendMsgApi({required String msg, required String model}) async {
    try {
      var response = await http.post(
        Uri.parse(ApiEndpoints.chatAiUrl),
        headers: {
          "Authorization": "Bearer ${ApiEndpoints.openAiApiKey}",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "model": model,
          "input": msg,
        }),
      );

      print(response.body.toString());

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['error'] != null) {
          throw HttpException(data['error']['message']);
        }
        return data;
      } else {
        throw HttpException("Error: ${response.statusCode}");
      }
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  dynamic _returnJsonResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body);
      case 400:
        throw BadRequestException(errorMsg: response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(errorMsg: response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            errorMsg: 'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}