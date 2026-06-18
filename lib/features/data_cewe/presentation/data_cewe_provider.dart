import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/data_cewe_service.dart';

class DataCeweNotifier extends Notifier<List<Map<String, dynamic>>> {
  bool isLoading = false;

  @override
  List<Map<String, dynamic>> build() {
    // Initial fetch
    Future.microtask(() => fetchData());
    return [];
  }

  Future<void> fetchData() async {
    isLoading = true;
    try {
      final service = ref.read(dataCeweServiceProvider);
      final data = await service.fetchGirlData();
      state = data;
    } catch (e) {
      debugPrint('Error fetching girl data: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> addData(String title, String description, String category) async {
    try {
      final service = ref.read(dataCeweServiceProvider);
      await service.addGirlData(title, description, category);
      await fetchData(); // Refresh list
    } catch (e) {
      debugPrint('Error adding girl data: $e');
      rethrow;
    }
  }
}

final dataCeweProvider = NotifierProvider<DataCeweNotifier, List<Map<String, dynamic>>>(() {
  return DataCeweNotifier();
});
