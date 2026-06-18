import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/theme/app_theme.dart';

class HighlightSyntax extends md.InlineSyntax {
  HighlightSyntax() : super(r'==([^=]+)==');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final element = md.Element.text('del', match[1]!);
    parser.addNode(element);
    return true;
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailScreen({super.key, required this.article});

  Future<void> _generatePdf(BuildContext context, String title, String content, String date) async {
    final doc = pw.Document();

    List<pw.TextSpan> parseMarkdown(String text) {
      final List<pw.TextSpan> spans = [];
      final pattern = RegExp(r'(==.*?==|\*\*.*?\*\*|\*.*?\*)');
      
      text.splitMapJoin(
        pattern,
        onMatch: (Match match) {
          final m = match[0]!;
          if (m.startsWith('==')) {
            spans.add(pw.TextSpan(
              text: m.substring(2, m.length - 2),
              style: pw.TextStyle(
                background: const pw.BoxDecoration(color: PdfColors.yellow),
                fontWeight: pw.FontWeight.bold,
              ),
            ));
          } else if (m.startsWith('**')) {
            spans.add(pw.TextSpan(
              text: m.substring(2, m.length - 2),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ));
          } else if (m.startsWith('*')) {
            spans.add(pw.TextSpan(
              text: m.substring(1, m.length - 1),
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ));
          }
          return '';
        },
        onNonMatch: (String nonMatch) {
          spans.add(pw.TextSpan(text: nonMatch));
          return '';
        },
      );
      
      return spans;
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Disimpan pada: $date', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
            pw.SizedBox(height: 24),
            pw.Divider(),
            pw.SizedBox(height: 24),
            pw.RichText(
              text: pw.TextSpan(
                style: const pw.TextStyle(fontSize: 12),
                children: parseMarkdown(content),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(bytes: await doc.save(), filename: '${title.replaceAll(' ', '_')}.pdf');
  }

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
              extensionSet: md.ExtensionSet.gitHubFlavored,
              inlineSyntaxes: [HighlightSyntax()],
              styleSheet: MarkdownStyleSheet(
                p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textDark,
                      height: 1.8,
                    ),
                strong: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                em: const TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textDark),
                del: TextStyle(
                  backgroundColor: Colors.yellow.withAlpha(150),
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _generatePdf(context, title, content, formattedDate),
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Download PDF'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.darkPastelPink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
