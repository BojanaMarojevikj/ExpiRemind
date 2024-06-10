import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/env.dart';

class OpenAIService {

  Future<String?> getRecommendations({required String prompt}) async {
    String apiKey = Env.key;
    const String baseUrl = "https://api.openai.com/v1/chat/completions";
    final Map<String, String> headers = {
      "Authorization": "Bearer $apiKey",
      "Content-Type": "application/json; charset=utf-8",
    };

    final body = jsonEncode({
      "model": "gpt-4-turbo",
      "messages": [
        {"role": "user", "content": prompt}
      ],
    });

    try {
      final response = await http.post(Uri.parse(baseUrl), headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data["choices"] as List;
        final choice = choices[0];
        final message = choice["message"] as Map;
        return message["content"] as String;
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch (error) {
      print("Error: $error");
      return null;
    }
  }

  Future<String?> generateImage(String prompt) async {
    String apiKey = Env.key;
    const String baseUrl = "https://api.openai.com/v1/images/generations";
    final Map<String, String> headers = {
      "Authorization": "Bearer $apiKey",
      "Content-Type": "application/json; charset=utf-8",
    };

    final body = jsonEncode({
      "model": "dall-e-3",
      "prompt": prompt,
      "n": 1,
      "size": "1024x1024"
    });

    try {
      final response = await http.post(Uri.parse(baseUrl), headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data["data"][0]["url"] as String;
        return imageUrl;
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch (error) {
      print("Error: $error");
      return null;
    }
  }
}