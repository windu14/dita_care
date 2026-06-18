import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  final String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> sendMessage(String message, List<Map<String, String>> history) async {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Groq API Key not found');
    }

    // Prepare messages payload
    final List<Map<String, String>> messages = [
      {
        'role': 'system',
        'content': 'Kamu adalah konsultan ahli psikologi dan karakter wanita bernama Dita Care. Tugasmu membantu user (laki-laki) memahami pasangannya dari segi sifat, mood (termasuk jadwal PMS), kode-kode, dan cara berkomunikasi yang baik. Jawablah dengan bahasa Indonesia yang santai, empatik, namun tetap berbobot dan informatif. Jangan terlalu panjang, berikan poin-poin jika perlu.'
      },
      ...history,
      {'role': 'user', 'content': message}
    ];

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': messages,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to send message: ${response.statusCode} - ${response.body}');
    }
  }
}
