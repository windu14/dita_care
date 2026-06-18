import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final dataCeweServiceProvider = Provider((ref) => DataCeweService());

class DataCeweService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchGirlData() async {
    final response = await _supabase.from('girl_data').select().order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addGirlData(String title, String description, String category) async {
    await _supabase.from('girl_data').insert({
      'title': title,
      'description': description,
      'category': category,
    });
  }
}
