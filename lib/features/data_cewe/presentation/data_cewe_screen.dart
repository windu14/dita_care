import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'data_cewe_provider.dart';

class DataCeweScreen extends ConsumerStatefulWidget {
  const DataCeweScreen({super.key});

  @override
  ConsumerState<DataCeweScreen> createState() => _DataCeweScreenState();
}

class _DataCeweScreenState extends ConsumerState<DataCeweScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  bool _isStackedExpanded = false;

  final List<String> _categories = [
    'Semua',
    'Makanan & Minuman Fav',
    'Tempat Fav',
    'Impian',
    'Pendidikan',
    'Fav Gift',
    'Outfit',
    'Hobi',
    'Tanggal Penting',
    'Lainnya'
  ];

  @override
  Widget build(BuildContext context) {
    final dataList = ref.watch(dataCeweProvider);
    
    final filteredData = dataList.where((item) {
      final title = (item['title'] ?? '').toString().toLowerCase();
      final desc = (item['description'] ?? '').toString().toLowerCase();
      final cat = (item['category'] ?? '');
      
      final matchesSearch = _searchQuery.isEmpty || 
          title.contains(_searchQuery.toLowerCase()) || 
          desc.contains(_searchQuery.toLowerCase());
          
      final matchesCategory = _selectedCategory == 'Semua' || cat == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();

    final isDefaultView = _searchQuery.isEmpty && _selectedCategory == 'Semua';
    final latest4 = dataList.take(4).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Data Si Dia'),
        backgroundColor: Colors.white,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              color: Colors.white,
              child: SearchBar(
                controller: _searchController,
                hintText: 'Cari makanan, hobi, tempat...',
                leading: const Icon(Icons.search, color: AppTheme.textLight),
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(AppTheme.backgroundLight),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                        selected: isSelected,
                        showCheckmark: false,
                        backgroundColor: AppTheme.backgroundLight,
                        selectedColor: AppTheme.darkPastelPink,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedCategory = cat;
                            // Reset expanded state if category changes
                            _isStackedExpanded = false;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          
          if (dataList.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            )
          else if (filteredData.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildSearchEmptyState(),
            )
          else if (isDefaultView)
            SliverToBoxAdapter(
              child: AnimatedCrossFade(
                firstChild: _buildStackedView(latest4),
                secondChild: _buildExpandedStackedView(filteredData),
                crossFadeState: _isStackedExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
                firstCurve: Curves.easeOutCubic,
                secondCurve: Curves.easeInCubic,
                sizeCurve: Curves.easeInOut,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildDataCard(filteredData[index]),
                    );
                  },
                  childCount: filteredData.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/data-cewe/form');
        },
        backgroundColor: AppTheme.darkPastelPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStackedView(List<Map<String, dynamic>> latest4) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Baru Saja Disimpan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _isStackedExpanded = true;
                  });
                },
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkPastelPink,
                  ),
                ),
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isStackedExpanded = true;
            });
          },
          child: SizedBox(
            height: 260, // Fixed height for stacked area
            child: Stack(
              alignment: Alignment.topCenter,
              children: List.generate(latest4.length, (index) {
                // Inverse index so newest (index 0) is drawn last and stays on top
                final itemIndex = latest4.length - 1 - index;
                final item = latest4[itemIndex];
                
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  top: itemIndex * 20.0,
                  left: 24.0 + (itemIndex * 12.0),
                  right: 24.0 + (itemIndex * 12.0),
                  child: IgnorePointer(
                    ignoring: itemIndex != 0, // Only top card is interactive
                    child: _buildDataCard(item, isStacked: true),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedStackedView(List<Map<String, dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 24, 8, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Semua Catatan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isStackedExpanded = false;
                    });
                  },
                  icon: const Icon(Icons.layers_clear, size: 16),
                  label: const Text('Tumpuk Kembali'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.darkPastelPink,
                  ),
                )
              ],
            ),
          ),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildDataCard(item),
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.darkPastelPink.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 80,
                color: AppTheme.darkPastelPink,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Catatan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Catat semua kesukaan, hobi, dan kode-kodenya di sini agar tidak lupa!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textLight,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 80,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak Ditemukan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data yang kamu cari tidak ada. Coba gunakan kata kunci lain atau periksa filter kategorinya.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textLight,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(Map<String, dynamic> item, {bool isStacked = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: isStacked ? [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ] : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item['title'] ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.darkPastelGreen.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item['category'] ?? '',
                    style: const TextStyle(
                      color: AppTheme.darkPastelGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item['description'] ?? 'Tidak ada deskripsi',
              style: const TextStyle(
                color: AppTheme.textDark,
                height: 1.5,
              ),
              maxLines: isStacked ? 2 : null,
              overflow: isStacked ? TextOverflow.ellipsis : null,
            ),
          ],
        ),
      ),
    );
  }
}
