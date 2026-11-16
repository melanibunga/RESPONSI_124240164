import 'package:flutter/material.dart';

import '../models/character.dart';
import '../services/favorites_store.dart';
import '../theme.dart';
import 'detail_screen.dart';
import 'widgets.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FavoritesStore.instance,
      builder: (context, _) {
        final items = FavoritesStore.instance.items;

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
                  child: const Icon(Icons.favorite_border,
                      size: 40, color: AppColors.olive),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Belum ada karakter favorit',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tekan ikon hati pada karakter untuk menambahkan',
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
            final Character c = items[i];
            return Dismissible(
              key: ValueKey(c.id),
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
                await FavoritesStore.instance.remove(c.id);
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text('${c.judul_berita} dihapus dari favorit'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () => FavoritesStore.instance.add(c),
                    ),
                  ));
              },
              child: CharacterCard(
                character: c,
                trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DetailScreen(character: c)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
