import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

class DetailDataCeweScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const DetailDataCeweScreen({super.key, required this.item});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = item['title'] ?? 'Tanpa Judul';
    final desc = item['description'] ?? 'Tidak ada deskripsi';
    final category = item['category'] ?? 'Lainnya';
    final imageUrl = item['image_url'];
    final link = item['link'];
    final bool hasImage = imageUrl != null && imageUrl.toString().isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: hasImage ? 300.0 : null,
            pinned: true,
            backgroundColor: AppTheme.backgroundLight,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              title: const SizedBox.shrink(),
              background: hasImage
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator(color: AppTheme.darkPastelPink)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.darkPastelGreen.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: AppTheme.darkPastelGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.notes_rounded, color: AppTheme.darkPastelPink, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Catatan Detail',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            desc,
                            style: const TextStyle(
                              color: AppTheme.textDark,
                              height: 1.6,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (link != null && link.toString().isNotEmpty)
          ? FloatingActionButton.extended(
              onPressed: () => _launchUrl(link),
              backgroundColor: AppTheme.darkPastelPink,
              elevation: 4,
              icon: const Icon(Icons.open_in_browser, color: Colors.white),
              label: const Text('Buka Tautan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }
}
