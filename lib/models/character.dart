class Character {
  final int id;
  final String judul_berita;
  final String sumber_berita;
  final String tgl_publikasi;
  final String penulis;
  final String ringkasan_berita;
  final String image;

  const Character({
    required this.id,
    required this.judul_berita,
    required this.sumber_berita,
    required this.tgl_publikasi,
    required this.penulis,
    required this.ringkasan_berita,
    required this.image,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      judul_berita: json['judul_berita'] as String? ?? '-',
      sumber_berita: json['sumber_berita'] as String? ?? 'unknown',
      tgl_publikasi: json['tgl_publikasi'] as String? ?? '-',
      penulis: json['penulis'] as String? ?? '-',
      ringkasan_berita: json['ringkasan_berita'] is Map
          ? (json['ringkasan_berita']['judul_berita'] as String? ?? '-')
          : (json['ringkasan_berita'] as String? ?? '-'),
      image: json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'judul_berita': judul_berita,
        'sumber_berita': sumber_berita,
        'tgl_publikasi': tgl_publikasi,
        'penulis': penulis,
        'ringkasan_berita': ringkasan_berita,
        'image': image,
      };
}
