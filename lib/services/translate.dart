import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslateService {
  final String _baseUrl = 'https://api.mymemory.translated.net/get'; // translator model

  Future<String> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    final url = Uri.parse(
      '$_baseUrl?q=${Uri.encodeComponent(text)}&langpair=$from|$to',
    );

    try { // response 
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['responseData']['translatedText'];
      } else {
        return 'Translate error: code ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}