import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteItem {
  final String key;
  final int bookId;
  final String bookTitle;
  final int chapter;
  final int paragraphIndex;
  final String text;
  final DateTime createdAt;

  FavoriteItem({
    required this.key,
    required this.bookId,
    required this.bookTitle,
    required this.chapter,
    required this.paragraphIndex,
    required this.text,
    required this.createdAt,
  });

  factory FavoriteItem.fromMap(Map<String, dynamic> m) {
    return FavoriteItem(
      key: m['key'] ?? '',
      bookId: (m['bookId'] is int) ? m['bookId'] as int : int.tryParse('${m['bookId']}'.replaceAll('b', '')) ?? 0,
      bookTitle: m['bookTitle'] ?? '',
      chapter: m['chapter'] is int ? m['chapter'] as int : int.tryParse('${m['chapter']}') ?? 0,
      paragraphIndex: m['paragraphIndex'] is int ? m['paragraphIndex'] as int : int.tryParse('${m['paragraphIndex']}') ?? 0,
      text: m['text'] ?? '',
      createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<FavoriteItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('favorites_items');
      List<FavoriteItem> items = [];
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        final list = (decoded as List).cast<Map<String, dynamic>>();
        items = list.map(FavoriteItem.fromMap).toList();
      }
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _removeFavorite(FavoriteItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('favorites_items');
    List<Map<String, dynamic>> list = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      } catch (_) {}
    }
    list.removeWhere((m) => (m['key'] ?? '') == item.key);
    await prefs.setString('favorites_items', jsonEncode(list));
    final keys = prefs.getStringList('favorites_key_set') ?? [];
    keys.remove(item.key);
    await prefs.setStringList('favorites_key_set', keys);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的收藏')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('还没有收藏内容'))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final it = _items[index];
                    return Dismissible(
                      key: Key(it.key),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _removeFavorite(it),
                      child: ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.redAccent),
                        title: Text(
                          it.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('${it.bookTitle} · 第${it.chapter + 1}章 · ${it.createdAt.toLocal()}'),
                      ),
                    );
                  },
                ),
    );
  }
}