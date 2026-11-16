import 'dart:async';

import 'package:flutter/material.dart';

import '../models/character.dart';
import '../services/api_service.dart';
import '../services/favorites_store.dart';
import '../theme.dart';
import 'detail_screen.dart';
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

  List<Character> _characters = [];
  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  String? _error;
  int _requestId = 0;

  String? _sumber_berita; // null = semua, 'alive' | 'dead' | 'unknown'
  String _query = '';

  static const _filters = <String?, String>{
    null: 'All',
    'alive': 'Alive',
    'dead': 'Dead',
    'unknown': 'Unknown',
  };

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 300) {
        _fetch();
      }
    });
    _fetch(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch({bool reset = false}) async {
    if (!reset && (_loading || !_hasMore || _error != null)) return;
    final id = ++_requestId;
    setState(() {
      if (reset) {
        _characters = [];
        _page = 1;
        _hasMore = true;
      }
      _loading = true;
      _error = null;
    });

    try {
      final res = await ApiService.fetchCharacters(
        page: _page,
        sumber_berita: _sumber_berita,
        judul_berita: _query,
      );
      if (!mounted || id != _requestId) return;
      setState(() {
        _characters.addAll(res.characters);
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

  void _onFilter(String? status) {
    if (_sumber_berita == status) return;
    _sumber_berita = status;
    _fetch(reset: true);
  }

  Future<void> _toggleFavorite(Character c) async {
    final added = await FavoritesStore.instance.toggle(c);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(added
            ? '${c.judul_berita} ditambahkan ke bookmark'
            : '${c.judul_berita} dihapus dari bookmark'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            children: _filters.entries.map((e) {
              final selected = _sumber_berita == e.key;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: ChoiceChip(
                  label: Text(e.value),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) => _onFilter(e.key),
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
    );
  }

  Widget _buildBody() {
    if (_characters.isEmpty) {
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
        itemCount: _characters.length + (showFooter ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= _characters.length) {
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

          final c = _characters[i];
          return CharacterCard(
            character: c,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DetailScreen(character: c)),
            ),
            trailing: ListenableBuilder(
              listenable: FavoritesStore.instance,
              builder: (context, _) {
                final fav = FavoritesStore.instance.isFavorite(c.id);
                return FavSquareButton(
                  active: fav,
                  tooltip: fav ? 'Hapus dari bookmark' : 'Tambah ke bookmark',
                  onPressed: () => _toggleFavorite(c),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
