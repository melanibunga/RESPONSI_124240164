/// Model berita dari Spaceflight News API v4.
class Article {
  final int id;
  final String title;
  final String newsSite;
  final String publishedAt; // format ISO 8601 dari API
  final String authors;
  final String summary;
  final String imageUrl;
  final String url;

  const Article({
    required this.id,
    required this.title,
    required this.newsSite,
    required this.publishedAt,
    required this.authors,
    required this.summary,
    required this.imageUrl,
    required this.url,
  });

  /// Dari response API.
  factory Article.fromJson(Map<String, dynamic> json) {
    final rawAuthors = json['authors'];
    var authors = '-';
    if (rawAuthors is List) {
      final names = rawAuthors
          .map((a) => a is Map ? (a['name'] as String? ?? '') : '')
          .where((n) => n.isNotEmpty)
          .toList();
      if (names.isNotEmpty) authors = names.join(', ');
    }
    return Article(
      id: json['id'] as int,
      title: json['title'] as String? ?? '-',
      newsSite: json['news_site'] as String? ?? 'unknown',
      publishedAt: json['published_at'] as String? ?? '',
      authors: authors,
      summary: json['summary'] as String? ?? '-',
      imageUrl: json['image_url'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  /// Dari / ke baris tabel `bookmarks` (SQLite).
  factory Article.fromMap(Map<String, dynamic> m) => Article(
        id: m['article_id'] as int,
        title: m['title'] as String? ?? '-',
        newsSite: m['news_site'] as String? ?? 'unknown',
        publishedAt: m['published_at'] as String? ?? '',
        authors: m['authors'] as String? ?? '-',
        summary: m['summary'] as String? ?? '-',
        imageUrl: m['image_url'] as String? ?? '',
        url: m['url'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'article_id': id,
        'title': title,
        'news_site': newsSite,
        'published_at': publishedAt,
        'authors': authors,
        'summary': summary,
        'image_url': imageUrl,
        'url': url,
      };

  /// Tanggal publikasi yang mudah dibaca, contoh: 16 Nov 2026.
  String get formattedDate {
    final d = DateTime.tryParse(publishedAt)?.toLocal();
    if (d == null) return '-';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
