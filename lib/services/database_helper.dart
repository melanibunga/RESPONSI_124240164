import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Local database (SQLite) untuk menyimpan akun user.
class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async => _db ??= await _init();

  static Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'rick_morty_app.db');
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
      },
    );
  }

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
}
