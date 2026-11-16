import 'package:flutter/material.dart';

import '../models/article.dart';
import '../theme.dart';

/// Snackbar bookmark: hijau kalau ditambahkan, merah kalau dihapus.
void showBookmarkSnackBar(
  BuildContext context, {
  required bool added,
  required String title,
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      backgroundColor: added ? Colors.green.shade700 : Colors.red.shade700,
      content: Text(added
          ? '$title ditambahkan ke bookmark'
          : '$title dihapus dari bookmark'),
      action: action,
    ));
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              child: const Icon(Icons.wifi_off_rounded,
                  size: 40, color: AppColors.olive),
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gambar berita berbentuk kotak membulat (dengan loading & fallback).
class ArticleImage extends StatelessWidget {
  final String url;
  final double? width;
  final double height;
  final double radius;
  const ArticleImage({
    super.key,
    required this.url,
    this.width,
    this.height = 72,
    this.radius = 14,
  });

  Widget _placeholder(IconData icon) => Container(
        width: width,
        height: height,
        color: AppColors.tint,
        child: Icon(icon, color: AppColors.muted),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url.isEmpty
          ? _placeholder(Icons.image_not_supported_outlined)
          : Image.network(
              url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : _placeholder(Icons.image_outlined),
              errorBuilder: (_, __, ___) =>
                  _placeholder(Icons.broken_image_outlined),
            ),
    );
  }
}

/// Tombol bookmark persegi membulat: aktif = hijau zaitun + ikon lime.
class BookmarkButton extends StatelessWidget {
  final bool active;
  final VoidCallback onPressed;
  final String? tooltip;
  final double size;
  const BookmarkButton({
    super.key,
    required this.active,
    required this.onPressed,
    this.tooltip,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: active ? AppColors.olive : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: active ? AppColors.olive : AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            active ? Icons.bookmark : Icons.bookmark_border,
            size: 19,
            color: active ? AppColors.lime : AppColors.muted,
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Kartu berita: gambar, tanggal, judul, sumber berita, dan widget di kanan.
class ArticleCard extends StatelessWidget {
  final Article article;
  final Widget trailing;
  final VoidCallback onTap;
  const ArticleCard({
    super.key,
    required this.article,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ArticleImage(url: article.imageUrl, width: 80, height: 80),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.tint,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article.formattedDate,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.olive,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.public,
                            size: 14, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            article.newsSite,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.muted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
