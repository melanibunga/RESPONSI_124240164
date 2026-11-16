import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';
import '../services/bookmark_store.dart';
import '../theme.dart';
import 'widgets.dart';

class DetailScreen extends StatelessWidget {
  final Article article;
  const DetailScreen({super.key, required this.article});

  Future<void> _toggle(BuildContext context) async {
    final added = await BookmarkStore.instance.toggle(article);
    if (!context.mounted) return;
    showBookmarkSnackBar(context, added: added, title: article.title);
  }

  Future<void> _openArticle(BuildContext context) async {
    final uri = Uri.tryParse(article.url);
    var ok = false;
    if (uri != null) {
      try {
        ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        ok = false;
      }
    }
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          backgroundColor: Colors.red.shade700,
          content: const Text('Tidak dapat membuka artikel'),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
        actions: [
          ListenableBuilder(
            listenable: BookmarkStore.instance,
            builder: (context, _) {
              final saved = BookmarkStore.instance.isBookmarked(article.id);
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: BookmarkButton(
                  active: saved,
                  tooltip: saved ? 'Hapus dari bookmark' : 'Tambah ke bookmark',
                  onPressed: () => _toggle(context),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ArticleImage(
                url: article.imageUrl,
                width: double.infinity,
                height: double.infinity,
                radius: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              article.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: _withDividers([
                  _row(context, Icons.public, 'Sumber', article.newsSite),
                  _row(context, Icons.calendar_today_outlined, 'Tanggal',
                      article.formattedDate),
                  _row(context, Icons.edit_outlined, 'Penulis',
                      article.authors),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ringkasan',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              article.summary,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _openArticle(context),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Read Full Article'),
              ),
            ),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable: BookmarkStore.instance,
              builder: (context, _) {
                final saved = BookmarkStore.instance.isBookmarked(article.id);
                return SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: saved ? AppColors.lime : Colors.white,
                      foregroundColor: AppColors.oliveDark,
                      side: BorderSide(
                          color: saved ? AppColors.lime : AppColors.olive),
                    ),
                    onPressed: () => _toggle(context),
                    icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                    label: Text(
                        saved ? 'Hapus dari Bookmark' : 'Tambah ke Bookmark'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.olive, size: 22),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> rows) {
    final out = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      out.add(rows[i]);
      if (i != rows.length - 1) {
        out.add(const Divider(height: 1, indent: 16, endIndent: 16));
      }
    }
    return out;
  }
}
