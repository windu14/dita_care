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
        'content': 'Kamu adalah konsultan ahli psikologi dan karakter wanita bernama Dita Care. '
            'Tugasmu KHUSUS membantu user (laki-laki) memahami pasangannya dari segi sifat, mood, trend cewe, kode-kode cewe, masa PMS, hadiah (gift), dan kepribadian. '
            'Gunakan bahasa Indonesia yang sangat friendly, gunakan sapaan "aku" dan "kamu", jangan kaku. '
            'Jika relevan, sertakan TEORI PSIKOLOGI HUBUNGAN secara ilmiah namun mudah dimengerti. '
            'Gunakan format MARKDOWN untuk menekankan hal penting. Gunakan **tebal** untuk inti poin, dan *miring* untuk penekanan. (Contoh: "Secara **teori psikologi**, wanita saat PMS mengalami fluktuasi hormon..."). '
            'ATURAN KERAS: Jika user bertanya hal di luar topik percintaan, psikologi wanita, atau hubungan, '
            'kamu WAJIB menolak dengan sopan dan mengingatkan bahwa kamu hanya melayani curhat soal pasangan.'
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
