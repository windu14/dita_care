import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/data_cewe_service.dart';

class DataCeweNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return _fetchData();
  }

  Future<List<Map<String, dynamic>>> _fetchData() async {
    try {
      // Simulate 3 seconds shimmer loading delay for native feel
      await Future.delayed(const Duration(seconds: 3));
      
      final service = ref.read(dataCeweServiceProvider);
      final data = await service.fetchGirlData();
      return data;
    } catch (e) {
      debugPrint('Error fetching girl data: $e');
      rethrow;
    }
  }

  Future<void> addData(String title, String description, String category, {String? imagePath, String? link}) async {
    try {
      final service = ref.read(dataCeweServiceProvider);
      await service.addGirlData(title, description, category, imagePath: imagePath, link: link);
      // Invalidate the provider to trigger a rebuild and re-fetch
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error adding girl data: $e');
      rethrow;
    }
  }
}

final dataCeweProvider = AsyncNotifierProvider<DataCeweNotifier, List<Map<String, dynamic>>>(() {
  return DataCeweNotifier();
});
