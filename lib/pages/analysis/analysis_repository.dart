import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AnalysisItem {
  final String id;
  final String title;
  final String content;
  final String author;
  final String bookTitle;
  final DateTime publishDate;
  int likeCount;

  AnalysisItem({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.bookTitle,
    required this.publishDate,
    this.likeCount = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'author': author,
        'bookTitle': bookTitle,
        'publishDate': publishDate.toIso8601String(),
        'likeCount': likeCount,
      };

  static AnalysisItem fromMap(Map<String, dynamic> m) => AnalysisItem(
        id: (m['id'] ?? '').toString(),
        title: (m['title'] ?? '') as String,
        content: (m['content'] ?? '') as String,
        author: (m['author'] ?? '') as String,
        bookTitle: (m['bookTitle'] ?? '') as String,
        publishDate: DateTime.tryParse(m['publishDate'] ?? '') ?? DateTime.now(),
        likeCount: (m['likeCount'] ?? 0) as int,
      );
}

class AnalysisRepository {
  static const _key = 'customAnalyses';
  static const _likeKey = 'analysisLikeCounts';
  static const _likedSetKey = 'analysisLikedSet';

  // 预置内置解析列表（模拟“最新解析”）
  static List<AnalysisItem> builtin() {
    final now = DateTime.now();
    return [
      AnalysisItem(
        id: 'a1',
        title: '《傲慢与偏见》人物关系解析',
        author: '王教授',
        bookTitle: '傲慢与偏见',
        content:
            '本文将深入分析《傲慢与偏见》中的人物关系，特别是伊丽莎白与达西的性格冲突与和解。',
        publishDate: now.subtract(const Duration(days: 7)),
        likeCount: 12,
      ),
      AnalysisItem(
        id: 'a2',
        title: '《双城记》历史背景探讨',
        author: '李老师',
        bookTitle: '双城记',
        content: '法国大革命如何影响了狄更斯的创作？从历史角度解读《双城记》。',
        publishDate: now.subtract(const Duration(days: 10)),
        likeCount: 9,
      ),
      AnalysisItem(
        id: 'a3',
        title: '《呼啸山庄》叙事结构分析',
        author: '张教授',
        bookTitle: '呼啸山庄',
        content: '多层嵌套的叙事框架如何增强了小说的神秘感和复杂性。',
        publishDate: now.subtract(const Duration(days: 15)),
        likeCount: 7,
      ),
    ];
  }

  Future<List<AnalysisItem>> listAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final custom = <AnalysisItem>[];
    if (raw != null && raw.isNotEmpty) {
      final arr = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      custom.addAll(arr.map(AnalysisItem.fromMap));
    }
    final all = [...builtin(), ...custom];
    all.sort((a, b) => b.publishDate.compareTo(a.publishDate));
    return all;
  }

  Future<List<AnalysisItem>> loadCustom() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final arr = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return arr.map(AnalysisItem.fromMap).toList();
  }

  Future<void> saveCustom(List<AnalysisItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final data = items.map((e) => e.toMap()).toList();
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<AnalysisItem?> getById(String id) async {
    final all = await listAll();
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  // 点赞：加载、保存以及覆盖列表中的点赞数
  Future<Map<String, int>> loadLikeCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_likeKey);
    if (raw == null || raw.isEmpty) return {};
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return m.map((k, v) => MapEntry(k, (v ?? 0) as int));
  }

  Future<void> saveLikeCounts(Map<String, int> counts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_likeKey, jsonEncode(counts));
  }

  Future<Set<String>> loadLikedSet() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_likedSetKey);
    if (raw == null || raw.isEmpty) return <String>{};
    final list = (jsonDecode(raw) as List).cast<String>();
    return list.toSet();
  }

  Future<void> saveLikedSet(Set<String> liked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_likedSetKey, jsonEncode(liked.toList()));
  }

  Future<List<AnalysisItem>> listAllWithLikeOverrides() async {
    final items = await listAll();
    final counts = await loadLikeCounts();
    for (final it in items) {
      final c = counts[it.id];
      if (c != null) it.likeCount = c;
    }
    return items;
  }

  // 切换点赞；返回新的点赞数
  Future<int> toggleLike(String id) async {
    final liked = await loadLikedSet();
    final counts = await loadLikeCounts();
    final item = await getById(id);
    final current = counts[id] ?? (item?.likeCount ?? 0);
    final isLiked = liked.contains(id);
    final next = isLiked ? (current > 0 ? current - 1 : 0) : current + 1;
    if (isLiked) {
      liked.remove(id);
    } else {
      liked.add(id);
    }
    counts[id] = next;
    await saveLikedSet(liked);
    await saveLikeCounts(counts);
    return next;
  }
}