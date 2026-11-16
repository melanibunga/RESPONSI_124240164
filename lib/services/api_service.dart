import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/character.dart';
// import '../models/episode.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class CharacterPage {
  final List<Character> characters;
  final bool hasNext;
  CharacterPage(this.characters, this.hasNext);
}

class ApiService {
  static const _base = 'https://api.spaceflightnewsapi.net/v4/articles';

  /// Return null kalau 404 dan [notFoundIsEmpty] true
  /// (API mengembalikan 404 untuk hasil filter/pencarian kosong).
  static Future<Map<String, dynamic>?> _get(
    Uri uri, {
    bool notFoundIsEmpty = false,
  }) async {
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode == 404 && notFoundIsEmpty) return null;
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

  /// GET /character  |  /character?sumber_berita=alive  |  &judul_berita=rick
  static Future<CharacterPage> fetchCharacters({
    int page = 1,
    String? sumber_berita,
    String? judul_berita,
  }) async {
    final params = <String, String>{'page': '$page'};
    if (sumber_berita != null && sumber_berita.isNotEmpty) params['sumber_berita'] = sumber_berita;
    if (judul_berita != null && judul_berita.trim().isNotEmpty) params['judul_berita'] = judul_berita.trim();

    final uri = Uri.parse('$_base/character').replace(queryParameters: params);
    final data = await _get(uri, notFoundIsEmpty: true);
    if (data == null) return CharacterPage([], false);

    final results = (data['results'] as List)
        .map((e) => Character.fromJson(e as Map<String, dynamic>))
        .toList();
    final hasNext = (data['info'] as Map<String, dynamic>)['next'] != null;
    return CharacterPage(results, hasNext);
  }

  /// GET /character/{id}
  static Future<Character> fetchCharacter(int id) async {
    final data = await _get(Uri.parse('$_base/character/$id'));
    return Character.fromJson(data!);
  }

  // /// GET /episode (semua halaman digabung)
  // static Future<List<Episode>> fetchEpisodes() async {
  //   final all = <Episode>[];
  //   String? next = '$_base/episode';
  //   while (next != null) {
  //     final data = await _get(Uri.parse(next));
  //     all.addAll((data!['results'] as List)
  //         .map((e) => Episode.fromJson(e as Map<String, dynamic>)));
  //     next = (data['info'] as Map<String, dynamic>)['next'] as String?;
  //   }
  //   return all;
  // }
}
