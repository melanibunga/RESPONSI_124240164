import 'dart:async';

import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/bookmark_store.dart';
import '../theme.dart';
import 'bookmark_screen.dart';
import 'detail_screen.dart';
import 'login_screen.dart';
import 'widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  String _username = '';
  List<Article> _articles = [];
  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  String? _error;
  int _requestId = 0;

  String? _newsSite; // null = semua sumber
  List<String> _newsSites = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 300) {
        _fetch();
      }
    });
    _loadUsername();
    _loadNewsSites();
    _fetch(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    final user = await AuthService.currentUser();
    if (!mounted) return;
    setState(() => _username = user ?? '');
  }

  /// Daftar sumber berita untuk filter (diambil dari API).
  Future<void> _loadNewsSites() async {
    try {
      final sites = await ApiService.fetchNewsSites();
      if (!mounted) return;
      setState(() => _newsSites = sites);
    } catch (_) {
      // Filter tetap bisa dipakai lewat "All"; abaikan kalau gagal.
    }
  }

  Future<void> _fetch({bool reset = false}) async {
    if (!reset && (_loading || !_hasMore || _error != null)) return;
    final id = ++_requestId;
    setState(() {
      if (reset) {
        _articles = [];
        _page = 1;
        _hasMore = true;
      }
      _loading = true;
      _error = null;
    });

    try {
      final res = await ApiService.fetchArticles(
        page: _page,
        newsSite: _newsSite,
        search: _query,
      );
      if (!mounted || id != _requestId) return;
      setState(() {
        _articles.addAll(res.articles);
        _hasMore = res.hasNext;
        if (res.hasNext) _page++;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {}); // update tombol clear
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _query = value.trim();
      _fetch(reset: true);
    });
  }

  void _onFilter(String? site) {
    if (_newsSite == site) return;
    _newsSite = site;
    _fetch(reset: true);
  }

  Future<void> _toggleBookmark(Article a) async {
    final added = await BookmarkStore.instance.toggle(a);
    if (!mounted) return;
    showBookmarkSnackBar(context, added: added, title: a.title);
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _appBarButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.line),
      ),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Title AppBar = username yang sedang login
        title: Text(_username),
        actions: [
          _appBarButton(
            tooltip: 'Bookmark',
            icon: Icons.bookmark_border,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BookmarkScreen()),
            ),
          ),
          const SizedBox(width: 8),
          _appBarButton(
            tooltip: 'Logout',
            icon: Icons.logout,
            onPressed: _logout,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari berita...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          _query = '';
                          _fetch(reset: true);
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: <String?>[null, ..._newsSites].map((site) {
                final selected = _newsSite == site;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: ChoiceChip(
                    label: Text(site ?? 'All'),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => _onFilter(site),
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.olive,
                    side: BorderSide(
                        color: selected ? AppColors.olive : AppColors.line),
                    shape: const StadiumBorder(),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : AppColors.ink,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_articles.isEmpty) {
      if (_loading) return const Center(child: CircularProgressIndicator());
      if (_error != null) {
        return ErrorView(message: _error!, onRetry: () => _fetch(reset: true));
      }
      return const Center(child: Text('Berita tidak ditemukan'));
    }

    final showFooter = _loading || _error != null;
    return RefreshIndicator(
      onRefresh: () => _fetch(reset: true),
      child: ListView.builder(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        itemCount: _articles.length + (showFooter ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= _articles.length) {
            if (_loading) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(_error ?? '', textAlign: TextAlign.center),
                  TextButton(
                    onPressed: () {
                      setState(() => _error = null);
                      _fetch();
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final a = _articles[i];
          return ArticleCard(
            article: a,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DetailScreen(article: a)),
            ),
            trailing: ListenableBuilder(
              listenable: BookmarkStore.instance,
              builder: (context, _) {
                final saved = BookmarkStore.instance.isBookmarked(a.id);
                return BookmarkButton(
                  active: saved,
                  tooltip: saved ? 'Hapus dari bookmark' : 'Tambah ke bookmark',
                  onPressed: () => _toggleBookmark(a),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
