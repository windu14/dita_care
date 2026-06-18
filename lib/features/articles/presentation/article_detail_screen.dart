import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/app_theme.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.parse(article['created_at']);
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(createdAt);
    final title = article['title'] ?? 'Tanpa Judul';
    final content = article['content'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Artikel'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.darkPastelGreen),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.darkPastelGreen,
                      ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Divider(),
            ),
            MarkdownBody(
              data: content,
              styleSheet: MarkdownStyleSheet(
                p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textDark,
                      height: 1.8,
                    ),
                strong: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                em: const TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textDark),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
