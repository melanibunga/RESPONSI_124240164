import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/bookmark_store.dart';
import '../theme.dart';
import 'detail_screen.dart';
import 'widgets.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmark')),
      body: ListenableBuilder(
        listenable: BookmarkStore.instance,
        builder: (context, _) {
          final items = BookmarkStore.instance.items;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: AppColors.tint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bookmark_border,
                        size: 40, color: AppColors.olive),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Belum ada bookmark',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tekan ikon bookmark pada berita untuk menambahkan',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final Article a = items[i];
              return Dismissible(
                key: ValueKey(a.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.only(right: 24),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  final messenger = ScaffoldMessenger.of(context);
                  await BookmarkStore.instance.remove(a.id);
                  messenger
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      backgroundColor: Colors.red.shade700,
                      content: Text('${a.title} dihapus dari bookmark'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        textColor: Colors.white,
                        onPressed: () => BookmarkStore.instance.add(a),
                      ),
                    ));
                },
                child: ArticleCard(
                  article: a,
                  trailing:
                      const Icon(Icons.chevron_right, color: AppColors.muted),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => DetailScreen(article: a)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
