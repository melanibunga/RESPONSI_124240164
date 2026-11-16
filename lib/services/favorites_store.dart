import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/character.dart';

/// Menyimpan daftar favorit (per user) di Shared Preferences.
/// Extends ChangeNotifier supaya Home, Detail, dan Favorite screen
/// otomatis ter-update ketika ada perubahan.
class FavoritesStore extends ChangeNotifier {
  FavoritesStore._();
  static final FavoritesStore instance = FavoritesStore._();

  String? _user;
  List<Character> _items = [];

  List<Character> get items => List.unmodifiable(_items);

  String get _key => 'favorites_$_user';

  bool isFavorite(int id) => _items.any((c) => c.id == id);

  Future<void> load(String username) async {
    _user = username;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      _items = [];
    } else {
      final list = jsonDecode(raw) as List;
      _items = list
          .map((e) => Character.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  void clear() {
    _user = null;
    _items = [];
    notifyListeners();
  }

  Future<void> _save() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_items.map((c) => c.toJson()).toList()),
    );
  }

  /// Return true kalau ditambahkan, false kalau dihapus.
  Future<bool> toggle(Character c) async {
    final added = !isFavorite(c.id);
    if (added) {
      _items.add(c);
    } else {
      _items.removeWhere((e) => e.id == c.id);
    }
    notifyListeners();
    await _save();
    return added;
  }

  Future<void> add(Character c) async {
    if (isFavorite(c.id)) return;
    _items.add(c);
    notifyListeners();
    await _save();
  }

  Future<void> remove(int id) async {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    await _save();
  }
}
