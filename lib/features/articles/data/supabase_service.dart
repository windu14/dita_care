import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<void> saveArticle(String content) async {
    await _client.from('articles').insert({
      'content': content,
    });
  }

  Future<List<Map<String, dynamic>>> getArticles() async {
    final response = await _client
        .from('articles')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}

final supabaseServiceProvider = Provider((ref) => SupabaseService());
