import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/article.dart';

/// Local database (SQLite): akun user dan bookmark berita.
class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async => _db ??= await _init();

  static Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'spacenews_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE bookmarks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            article_id INTEGER NOT NULL,
            title TEXT,
            news_site TEXT,
            published_at TEXT,
            authors TEXT,
            summary TEXT,
            image_url TEXT,
            url TEXT,
            UNIQUE(username, article_id)
          )
        ''');
      },
    );
  }

  // ---------------------------------------------------------------- users

  static Future<bool> insertUser(String username, String passwordHash) async {
    final db = await database;
    try {
      await db.insert(
        'users',
        {'username': username, 'password': passwordHash},
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return true;
    } catch (_) {
      return false; // username sudah dipakai
    }
  }

  static Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  // ------------------------------------------------------------ bookmarks

  /// Bookmark milik [username], yang terbaru di atas.
  static Future<List<Article>> getBookmarks(String username) async {
    final db = await database;
    final rows = await db.query(
      'bookmarks',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'id DESC',
    );
    return rows.map(Article.fromMap).toList();
  }

  static Future<void> insertBookmark(String username, Article a) async {
    final db = await database;
    await db.insert(
      'bookmarks',
      {'username': username, ...a.toMap()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteBookmark(String username, int articleId) async {
    final db = await database;
    await db.delete(
      'bookmarks',
      where: 'username = ? AND article_id = ?',
      whereArgs: [username, articleId],
    );
  }
}
