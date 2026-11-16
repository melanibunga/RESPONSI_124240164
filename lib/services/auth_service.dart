import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_helper.dart';
import 'favorites_store.dart';

/// Register/login memakai local database (SQLite),
/// sedangkan status sesi login disimpan di Shared Preferences.
class AuthService {
  static const _sessionKey = 'session_user';

  static String _hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  /// Return null kalau sukses, atau pesan error.
  static Future<String?> register(String username, String password) async {
    final u = username.trim().toLowerCase();
    final ok = await DatabaseHelper.insertUser(u, _hash(password));
    return ok ? null : 'Username sudah digunakan';
  }

  /// Return null kalau sukses, atau pesan error.
  static Future<String?> login(String username, String password) async {
    final u = username.trim().toLowerCase();
    final user = await DatabaseHelper.getUser(u);
    if (user == null) return 'Akun tidak ditemukan';
    if (user['password'] != _hash(password)) return 'Password salah';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, u);
    await FavoritesStore.instance.load(u);
    return null;
  }

  static Future<String?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    FavoritesStore.instance.clear();
  }
}
