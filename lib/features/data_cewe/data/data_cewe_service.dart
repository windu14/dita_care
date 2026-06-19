import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final dataCeweServiceProvider = Provider((ref) => DataCeweService());

class DataCeweService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchGirlData() async {
    final response = await _supabase.from('girl_data').select().order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addGirlData(String title, String description, String category, {String? imagePath, String? link}) async {
    String? imageUrl;

    if (imagePath?.isNotEmpty == true) {
      final file = File(imagePath!);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
      
      await _supabase.storage.from('data_cewe_images').upload(fileName, file);
      imageUrl = _supabase.storage.from('data_cewe_images').getPublicUrl(fileName);
    }

    await _supabase.from('girl_data').insert({
      'title': title,
      'description': description,
      'category': category,
      'image_url': imageUrl,
      'link': link,
    });
  }
}
