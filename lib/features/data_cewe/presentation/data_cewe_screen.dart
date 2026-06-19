import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
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
  int _displayCount = 5;
  
  bool _isSearchLoading = false;
  Timer? _searchTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

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
    final asyncDataList = ref.watch(dataCeweProvider);

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
                backgroundColor: const WidgetStatePropertyAll(AppTheme.backgroundLight),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _displayCount = 5;
                    _isSearchLoading = true;
                  });
                  _searchTimer?.cancel();
                  _searchTimer = Timer(const Duration(seconds: 3), () {
                    if (mounted) {
                      setState(() {
                        _isSearchLoading = false;
                      });
                    }
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
                            _displayCount = 5;
                            _isStackedExpanded = false;
                            _isSearchLoading = true;
                          });
                          _searchTimer?.cancel();
                          _searchTimer = Timer(const Duration(seconds: 3), () {
                            if (mounted) {
                              setState(() {
                                _isSearchLoading = false;
                              });
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          asyncDataList.when(
            loading: () => SliverFillRemaining(child: _buildShimmerLoading()),
            error: (error, stack) => SliverFillRemaining(child: Center(child: Text('Error: $error'))),
            data: (dataList) {
              if (_isSearchLoading) {
                return SliverFillRemaining(child: _buildShimmerLoading());
              }

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

              if (dataList.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                );
              } else if (filteredData.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildSearchEmptyState(),
                );
              } else if (isDefaultView) {
                final latestItems = filteredData.take(4).toList();
                final olderItems = filteredData.skip(4).toList();
                
                final paginatedOlderItems = olderItems.take(_displayCount).toList();
                final hasMore = olderItems.length > _displayCount;

                return SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildAnimatedStack(latestItems),
                    ),
                    if (paginatedOlderItems.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index == paginatedOlderItems.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                                  child: Center(
                                    child: FilledButton.tonal(
                                      onPressed: () {
                                        setState(() {
                                          _displayCount += 5;
                                        });
                                      },
                                      child: const Text('Tampilkan Lebih Banyak'),
                                    ),
                                  ),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildDataCard(paginatedOlderItems[index]),
                              );
                            },
                            childCount: paginatedOlderItems.length + (hasMore ? 1 : 0),
                          ),
                        ),
                      ),
                  ],
                );
              } else {
                final paginatedFilteredData = filteredData.take(_displayCount).toList();
                final hasMore = filteredData.length > _displayCount;

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == paginatedFilteredData.length) {
                           return Padding(
                             padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                             child: Center(
                               child: FilledButton.tonal(
                                 onPressed: () {
                                   setState(() {
                                     _displayCount += 5;
                                   });
                                 },
                                 child: const Text('Tampilkan Lebih Banyak'),
                               ),
                             ),
                           );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildDataCard(paginatedFilteredData[index]),
                        );
                      },
                      childCount: paginatedFilteredData.length + (hasMore ? 1 : 0),
                    ),
                  ),
                );
              }
            },
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

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          padding: const EdgeInsets.all(20),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 150,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedStack(List<Map<String, dynamic>> items) {
    const double cardHeight = 160.0;
    const double expandedSpacing = 16.0;
    const double headerHeight = 60.0;
    
    // Calculate total height needed for the stack container
    final double stackedHeight = 260.0;
    final double expandedHeight = headerHeight + (items.length * (cardHeight + expandedSpacing));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isStackedExpanded ? 'Semua Catatan' : 'Baru Saja Disimpan',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _isStackedExpanded = !_isStackedExpanded;
                  });
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _isStackedExpanded ? 'Tumpuk Kembali' : 'Lihat Semua',
                    key: ValueKey(_isStackedExpanded),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkPastelPink,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            if (!_isStackedExpanded) {
              setState(() {
                _isStackedExpanded = true;
              });
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutExpo,
            height: _isStackedExpanded ? expandedHeight : stackedHeight,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: List.generate(items.length, (i) {
                // Reverse index so 0 (newest) is drawn last and sits on top
                final index = items.length - 1 - i;
                final item = items[index];
                
                final bool isVisibleWhenStacked = index < 4;
                
                // Stacked layout calculations
                final double stackedTop = isVisibleWhenStacked ? index * 20.0 : 0.0;
                final double stackedLeftRight = 24.0 + (isVisibleWhenStacked ? index * 12.0 : 48.0);
                final double stackedOpacity = isVisibleWhenStacked ? 1.0 : 0.0;
                
                // Expanded layout calculations
                final double expandedTop = index * (cardHeight + expandedSpacing);
                final double expandedLeftRight = 16.0;
                
                return AnimatedPositioned(
                  key: ValueKey(item['id'] ?? index),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutExpo,
                  top: _isStackedExpanded ? expandedTop : stackedTop,
                  left: _isStackedExpanded ? expandedLeftRight : stackedLeftRight,
                  right: _isStackedExpanded ? expandedLeftRight : stackedLeftRight,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: _isStackedExpanded ? 1.0 : stackedOpacity,
                    child: IgnorePointer(
                      ignoring: !_isStackedExpanded && index != 0,
                      child: SizedBox(
                        height: cardHeight,
                        child: _buildDataCard(item, isStacked: !_isStackedExpanded),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
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
    return GestureDetector(
      onTap: () {
        context.push('/data-cewe/detail', extra: item);
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
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
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    ),
  );
}
}
