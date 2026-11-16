import 'package:flutter/foundation.dart';

import '../models/article.dart';
import 'database_helper.dart';

/// Daftar bookmark (per user) yang disimpan di local database (SQLite).
/// Extends ChangeNotifier supaya Home, Detail, dan Bookmark screen
/// otomatis ter-update ketika ada perubahan.
class BookmarkStore extends ChangeNotifier {
  BookmarkStore._();
  static final BookmarkStore instance = BookmarkStore._();

  String? _user;
  List<Article> _items = [];

  List<Article> get items => List.unmodifiable(_items);

  bool isBookmarked(int id) => _items.any((a) => a.id == id);

  Future<void> load(String username) async {
    _user = username;
    _items = await DatabaseHelper.getBookmarks(username);
    notifyListeners();
  }

  void clear() {
    _user = null;
    _items = [];
    notifyListeners();
  }

  /// Return true kalau ditambahkan, false kalau dihapus.
  Future<bool> toggle(Article a) async {
    if (isBookmarked(a.id)) {
      await remove(a.id);
      return false;
    }
    await add(a);
    return true;
  }

  Future<void> add(Article a) async {
    final user = _user;
    if (user == null || isBookmarked(a.id)) return;
    _items.insert(0, a);
    notifyListeners();
    await DatabaseHelper.insertBookmark(user, a);
  }

  Future<void> remove(int id) async {
    final user = _user;
    if (user == null) return;
    _items.removeWhere((a) => a.id == id);
    notifyListeners();
    await DatabaseHelper.deleteBookmark(user, id);
  }
}
