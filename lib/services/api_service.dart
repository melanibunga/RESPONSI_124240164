import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/article.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ArticlePage {
  final List<Article> articles;
  final bool hasNext;
  ArticlePage(this.articles, this.hasNext);
}

class ApiService {
  static const _base = 'https://api.spaceflightnewsapi.net/v4';

  /// Jumlah berita per halaman (soal: minimal 10).
  static const pageSize = 10;

  static Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        throw ApiException('Server bermasalah (kode ${res.statusCode})');
      }
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Coba lagi.');
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet.');
    } on http.ClientException {
      throw ApiException('Gagal terhubung ke server.');
    } on FormatException {
      throw ApiException('Format data tidak valid.');
    }
  }

  /// GET /articles/?limit=10&offset=0&news_site=NASA&search=mars
  static Future<ArticlePage> fetchArticles({
    int page = 1,
    String? newsSite,
    String? search,
  }) async {
    final params = <String, String>{
      'limit': '$pageSize',
      'offset': '${(page - 1) * pageSize}',
      'ordering': '-published_at',
    };
    if (newsSite != null && newsSite.isNotEmpty) params['news_site'] = newsSite;
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    final uri =
        Uri.parse('$_base/articles/').replace(queryParameters: params);
    final data = await _get(uri);

    final results = (data['results'] as List)
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
    return ArticlePage(results, data['next'] != null);
  }

  /// GET /info -> daftar semua news site untuk fitur filter.
  static Future<List<String>> fetchNewsSites() async {
    final data = await _get(Uri.parse('$_base/info/'));
    final sites = (data['news_sites'] as List).map((e) => e.toString()).toList();
    sites.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sites;
  }
}
