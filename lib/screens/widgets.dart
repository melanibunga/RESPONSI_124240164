import 'package:flutter/material.dart';

import '../models/character.dart';
import '../theme.dart';

Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'alive':
      return const Color(0xFF2FBF71);
    case 'dead':
      return AppColors.danger;
    default:
      return const Color(0xFFA0A396);
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  final TextStyle? style;
  const StatusBadge(this.status, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final c = statusColor(status);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(status, style: style),
      ],
    );
  }
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

/// Foto karakter berbentuk kotak membulat.
class CharacterAvatar extends StatelessWidget {
  final String url;
  final double size;
  const CharacterAvatar({super.key, required this.url, this.size = 60});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: AppColors.tint,
          child: const Icon(Icons.person, color: AppColors.muted),
        ),
      ),
    );
  }
}

/// Tombol hati persegi membulat: aktif = hijau zaitun + hati lime.
class FavSquareButton extends StatelessWidget {
  final bool active;
  final VoidCallback onPressed;
  final String? tooltip;
  final double size;
  const FavSquareButton({
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
            active ? Icons.favorite : Icons.favorite_border,
            size: 19,
            color: active ? AppColors.lime : AppColors.muted,
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Kartu karakter: foto, tag spesies, nama, status, dan widget di kanan.
class CharacterCard extends StatelessWidget {
  final Character character;
  final Widget trailing;
  final VoidCallback onTap;
  const CharacterCard({
    super.key,
    required this.character,
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
              CharacterAvatar(url: character.image),
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
                        character.tgl_publikasi,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.olive,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      character.judul_berita,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StatusBadge(
                      character.sumber_berita,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted),
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
