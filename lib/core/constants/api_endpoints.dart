import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static const String newsBaseUrl = "https://newsapi.org/v2/";

  // Ab asli key ki jagah .env se data read hoga
  static String get newsApiKey => dotenv.env['NEWS_API_KEY'] ?? "";

  static const String topHeadlinesUrl = "${newsBaseUrl}top-headlines";
  static const String everyThingUrl = "${newsBaseUrl}everything";

  static const String chatAiUrl = "https://api.openai.com/v1/responses";

  // for Key Saftey
  static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? "";
}