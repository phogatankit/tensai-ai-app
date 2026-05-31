import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static const String chatAiUrl = "https://api.openai.com/v1/responses";
  static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? "";
}