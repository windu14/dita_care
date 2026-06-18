import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dita Care'),
        actions: [
          IconButton(
            icon: const Icon(Icons.article_outlined),
            onPressed: () => context.pushNamed('articles'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Selamat datang di Dita Care',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.darkPastelPink,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Panduan lengkap memahami sifat, karakter, dan kode dari dia.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLight,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              _buildCard(
                context: context,
                title: 'Konsultasi AI',
                description: 'Tanya apa saja seputar pasanganmu, dari mood swing, kode rahasia, sampai jadwal PMS.',
                icon: Icons.chat_bubble_outline,
                color: AppTheme.darkPastelPink,
                onTap: () => context.pushNamed('chat'),
              ),
              const SizedBox(height: 16),
              
              _buildCard(
                context: context,
                title: 'Artikel & Catatan',
                description: 'Kumpulan jawaban dan tips terbaik yang kamu simpan dari konsultasi sebelumnya.',
                icon: Icons.bookmarks_outlined,
                color: AppTheme.darkPastelGreen,
                onTap: () => context.pushNamed('articles'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('chat'),
        icon: const Icon(Icons.chat),
        label: const Text('Mulai Chat'),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textDark,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
