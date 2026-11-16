import 'package:flutter/material.dart';

import '../models/character.dart';
import '../services/api_service.dart';
import '../services/favorites_store.dart';
import '../theme.dart';
import 'widgets.dart';

class DetailScreen extends StatefulWidget {
  final Character character;
  const DetailScreen({super.key, required this.character});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Character> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchCharacter(widget.character.id);
  }

  void _retry() {
    setState(() {
      _future = ApiService.fetchCharacter(widget.character.id);
    });
  }

  Future<void> _toggle(Character c) async {
    final added = await FavoritesStore.instance.toggle(c);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(added
            ? '${c.judul_berita} ditambahkan ke favorit'
            : '${c.judul_berita} dihapus dari favorit'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.character.judul_berita),
        actions: [
          ListenableBuilder(
            listenable: FavoritesStore.instance,
            builder: (context, _) {
              final fav =
                  FavoritesStore.instance.isFavorite(widget.character.id);
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: FavSquareButton(
                  active: fav,
                  tooltip: fav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                  onPressed: () => _toggle(widget.character),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Character>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ErrorView(message: snap.error.toString(), onRetry: _retry);
          }
          return _content(snap.data!);
        },
      ),
    );
  }

  Widget _content(Character c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.network(
              c.image,
              width: 260,
              height: 260,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  width: 260,
                  height: 260,
                  color: AppColors.tint,
                  child: const Icon(Icons.broken_image,
                      size: 64, color: AppColors.muted)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            c.judul_berita,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: _withDividers([
                _row(Icons.monitor_heart_outlined, 'Status', StatusBadge(c.sumber_berita)),
                _row(Icons.pets_outlined, 'Species', Text(c.tgl_publikasi)),
                _row(Icons.wc, 'Gender', Text(c.penulis)),
                _row(Icons.public, 'Origin', Text(c.ringkasan_berita)),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          ListenableBuilder(
            listenable: FavoritesStore.instance,
            builder: (context, _) {
              final fav = FavoritesStore.instance.isFavorite(c.id);
              return SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: fav ? AppColors.lime : AppColors.olive,
                    foregroundColor: fav ? AppColors.oliveDark : Colors.white,
                  ),
                  onPressed: () => _toggle(c),
                  icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
                  label: Text(fav ? 'Hapus dari Favorit' : 'Tambah ke Favorit'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, Widget value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.olive),
      title: Text(label,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 180),
        child: DefaultTextStyle.merge(
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
          child: value,
        ),
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
