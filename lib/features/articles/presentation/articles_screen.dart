import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../data/supabase_service.dart';

final articlesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // Simulate 3 seconds shimmer loading delay for native feel
  await Future.delayed(const Duration(seconds: 3));
  
  final service = ref.watch(supabaseServiceProvider);
  return await service.getArticles();
});

class ArticlesScreen extends ConsumerStatefulWidget {
  const ArticlesScreen({super.key});

  @override
  ConsumerState<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends ConsumerState<ArticlesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  bool _isSearchLoading = false;
  Timer? _searchTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _triggerSearch(String query) {
    setState(() {
      _searchQuery = query;
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
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsyncValue = ref.watch(articlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel Tersimpan'),
        backgroundColor: AppTheme.backgroundLight,
      ),
      backgroundColor: AppTheme.backgroundLight,
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(articlesProvider.future),
        color: AppTheme.darkPastelPink,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Cari judul atau isi artikel...',
                  leading: const Icon(Icons.search, color: AppTheme.textLight),
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(AppTheme.backgroundLight.withAlpha(200)),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onChanged: _triggerSearch,
                  trailing: [
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _triggerSearch('');
                        },
                      )
                  ],
                ),
              ),
            ),
            if (_searchQuery.isEmpty)
              SliverToBoxAdapter(
                child: _buildHeaders(),
              ),
            articlesAsyncValue.when(
              loading: () => _buildShimmerSliver(),
              error: (error, stack) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (articles) {
                if (_isSearchLoading) return _buildShimmerSliver();

                if (articles.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context),
                  );
                }

                if (_searchQuery.isEmpty) {
                  final recentArticles = articles.take(3).toList();
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildArticleCard(context, recentArticles[index]),
                        childCount: recentArticles.length,
                      ),
                    ),
                  );
                } else {
                  final filteredArticles = articles.where((article) {
                    final title = (article['title'] ?? '').toString().toLowerCase();
                    final content = (article['content'] ?? '').toString().toLowerCase();
                    final query = _searchQuery.toLowerCase();
                    return title.contains(query) || content.contains(query);
                  }).toList();

                  if (filteredArticles.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildSearchEmptyState(),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildArticleCard(context, filteredArticles[index]),
                        childCount: filteredArticles.length,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                Icons.menu_book_rounded,
                size: 80,
                color: AppTheme.darkPastelPink,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Pustaka Masih Kosong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tandai jawaban menarik dari Dita di obrolan untuk menyimpannya di sini.',
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
            const Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: 16),
            const Text(
              'Pencarian Tidak Ditemukan',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba gunakan kata kunci lain.',
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkPastelGreen.withAlpha(20),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates_rounded, color: AppTheme.darkPastelGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ketik judul untuk mencari artikel, atau sentuh kata kunci di bawah ini.',
                    style: TextStyle(color: AppTheme.darkPastelGreen.withAlpha(200)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Topik Populer',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildKeywordPill('Mood Swing'),
                const SizedBox(width: 8),
                _buildKeywordPill('Terserah'),
                const SizedBox(width: 8),
                _buildKeywordPill('Minta Maaf'),
                const SizedBox(width: 8),
                _buildKeywordPill('Komunikasi'),
                const SizedBox(width: 8),
                _buildKeywordPill('Hadiah/Gift'),
                const SizedBox(width: 8),
                _buildKeywordPill('Jadwal PMS'),
                const SizedBox(width: 8),
                _buildKeywordPill('Kode Cewe'),
                const SizedBox(width: 8),
                _buildKeywordPill('Kepribadian'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Baru Saja Disimpan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildKeywordPill(String keyword) {
    return ActionChip(
      label: Text(keyword),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFE0E0E0)),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () {
        _searchController.text = keyword;
        _triggerSearch(keyword);
      },
    );
  }

  Widget _buildArticleCard(BuildContext context, Map<String, dynamic> article) {
    final createdAt = DateTime.parse(article['created_at']);
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/articles/article-detail', extra: article);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article['title'] ?? 'Tanpa Judul',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                formattedDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.darkPastelGreen,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(height: 1),
              ),
              Text(
                article['content'] ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textDark,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Baca selengkapnya...',
                    style: TextStyle(
                      color: AppTheme.darkPastelPink,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerSliver() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 250,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(50),
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(50),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(50),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(50),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(50),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          childCount: 5,
        ),
      ),
    );
  }
}
