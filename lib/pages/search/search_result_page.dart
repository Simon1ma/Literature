import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../reader/book_reader_page.dart';
import '../../services/api_client.dart';

class SearchResultPage extends StatefulWidget {
  final String initialQuery;

  const SearchResultPage({super.key, this.initialQuery = ''});

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;

  // 搜索历史
  final List<String> _searchHistory = [
    '莎士比亚',
    '傲慢与偏见',
    '双城记',
    '文学分析方法',
    '现代主义文学',
  ];

  // 搜索结果（仅名著）
  final Map<String, List<dynamic>> _searchResults = {
    'books': [],
  };

  bool _isSearching = false;
  bool _showHistory = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _searchController = TextEditingController(text: widget.initialQuery);

    if (widget.initialQuery.isNotEmpty) {
      _performSearch(widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 执行搜索
  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _showHistory = true;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showHistory = false;
    });

    // 调用后端搜索图书，并与前端本地名著库合并
    ApiClient().searchBooks(query).then((items) {
      // 历史记录
      if (!_searchHistory.contains(query)) {
        setState(() {
          _searchHistory.insert(0, query);
          if (_searchHistory.length > 10) {
            _searchHistory.removeLast();
          }
        });
      }

      final mappedBackend = items.map((b) {
        final idStr = (b['id'] ?? '').toString();
        // 将后端 id 如 "b1" 转换为数字 1 供阅读页使用
        final numericId = int.tryParse(idStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return {
          'id': idStr,
          'numericId': numericId,
          'title': b['title'] ?? '',
          'author': b['author'] ?? '',
          'category': '小说',
          'wordCount': '?',
          'coverUrl': null,
          'description': b['description'] ?? '',
        };
      }).toList();

      // 前端本地名著库（包含莎士比亚等），按查询过滤
      final localBooks = _generateMockBooks(query).map((lb) {
        final idStr = (lb['id'] ?? '').toString();
        final numericId = int.tryParse(idStr) ?? 0;
        return {
          'id': idStr,
          'numericId': numericId,
          'title': lb['title'] ?? '',
          'author': lb['author'] ?? '',
          'category': lb['category'] ?? '名著',
          'wordCount': lb['wordCount'] ?? '?',
          'coverUrl': lb['coverUrl'],
          'description': '',
        };
      }).toList();

      // 合并并按标题去重，确保前端可见
      final List<Map<String, dynamic>> combined = [];
      final Set<String> seenTitles = {};
      for (final b in [...mappedBackend, ...localBooks]) {
        final title = (b['title'] ?? '').toString();
        if (title.isEmpty) continue;
        if (seenTitles.add(title)) {
          combined.add(b);
        }
      }

      setState(() {
        _searchResults['books'] = combined;
        _isSearching = false;
      });
    }).catchError((e) {
      // 后端异常时，前端仍提供本地名著结果
      final localBooks = _generateMockBooks(query).map((lb) {
        final idStr = (lb['id'] ?? '').toString();
        final numericId = int.tryParse(idStr) ?? 0;
        return {
          'id': idStr,
          'numericId': numericId,
          'title': lb['title'] ?? '',
          'author': lb['author'] ?? '',
          'category': lb['category'] ?? '名著',
          'wordCount': lb['wordCount'] ?? '?',
          'coverUrl': lb['coverUrl'],
          'description': '',
        };
      }).toList();
      setState(() {
        _searchResults['books'] = localBooks;
        _isSearching = false;
      });
      Fluttertoast.showToast(msg: '后端搜索失败，已显示前端内置名著');
    });
  }

  // 清除搜索历史
  void _clearSearchHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除搜索历史'),
        content: const Text('确定要清除所有搜索历史吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _searchHistory.clear();
              });
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: '搜索历史已清除',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '搜索英文名著...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _showHistory = true;
                });
              },
            ),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
        ),
        bottom: _showHistory
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '名著'),
                ],
              ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _showHistory
          ? _buildSearchHistory()
          : TabBarView(
              controller: _tabController,
              children: [
                // 仅保留名著搜索结果
                _buildBookResults(),
              ],
            ),
    );
  }

  // 构建搜索历史
  Widget _buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '搜索历史',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (_searchHistory.isNotEmpty)
                TextButton(
                  onPressed: _clearSearchHistory,
                  child: const Text('清除'),
                ),
            ],
          ),
        ),
        if (_searchHistory.isEmpty)
          const Center(
            child: Padding(padding: EdgeInsets.all(32), child: Text('暂无搜索历史')),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _searchHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(_searchHistory[index]),
                  onTap: () {
                    _searchController.text = _searchHistory[index];
                    _performSearch(_searchHistory[index]);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _searchHistory.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }


  // 构建名著搜索结果
  Widget _buildBookResults() {
    final books = _searchResults['books'] as List;

    if (books.isEmpty) {
      return const Center(child: Text('未找到相关名著'));
    }

    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: book['coverUrl'] != null
                ? Image.network(book['coverUrl'], fit: BoxFit.cover)
                : const Icon(Icons.book, size: 30),
          ),
          title: Text(book['title']),
          subtitle: Text('${book['author']} · ${book['category']}'),
          trailing: Text('${book['wordCount']}字'),
          onTap: () {
            final bookId = (book['numericId'] as int?) ?? 0;
            final bookTitle = book['title'].toString();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookReaderPage(
                  bookId: bookId,
                  bookTitle: bookTitle,
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 构建解析搜索结果
  Widget _buildAnalysisResults() {
    final analyses = _searchResults['analyses'] as List;

    if (analyses.isEmpty) {
      return const Center(child: Text('未找到相关解析'));
    }

    return ListView.builder(
      itemCount: analyses.length,
      itemBuilder: (context, index) {
        final analysis = analyses[index];
        return ListTile(
          leading: const Icon(Icons.article),
          title: Text(analysis['title']),
          subtitle: Text('${analysis['bookTitle']} · ${analysis['author']}'),
          trailing: Text('${analysis['viewCount']}次阅读'),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/analysis',
              arguments: {'analysisId': analysis['id']},
            );
          },
        );
      },
    );
  }

  // 构建笔记搜索结果
  Widget _buildNoteResults() {
    final notes = _searchResults['notes'] as List;

    if (notes.isEmpty) {
      return const Center(child: Text('未找到相关笔记'));
    }

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          leading: const Icon(Icons.note),
          title: Text(
            note['content'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('${note['bookTitle']} · ${note['chapterTitle']}'),
          trailing: Text(note['createTime']),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/notes',
              arguments: {'noteId': note['id']},
            );
          },
        );
      },
    );
  }

  // 构建讨论搜索结果
  Widget _buildDiscussionResults() {
    final discussions = _searchResults['discussions'] as List;

    if (discussions.isEmpty) {
      return const Center(child: Text('未找到相关讨论'));
    }

    return ListView.builder(
      itemCount: discussions.length,
      itemBuilder: (context, index) {
        final discussion = discussions[index];
        return ListTile(
          leading: const Icon(Icons.forum),
          title: Text(discussion['title']),
          subtitle: Text(
            '${discussion['author']} · ${discussion['createTime']}',
          ),
          trailing: Text('${discussion['replyCount']}回复'),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/discussion',
              arguments: {'topicId': discussion['id']},
            );
          },
        );
      },
    );
  }

  // 生成模拟名著数据
  List<Map<String, dynamic>> _generateMockBooks(String query) {
    final books = [
      {
        'id': '1',
        'title': '傲慢与偏见',
        'author': '简·奥斯汀',
        'category': '小说',
        'wordCount': '120,000',
        'coverUrl': null,
      },
      {
        'id': '2',
        'title': '双城记',
        'author': '查尔斯·狄更斯',
        'category': '小说',
        'wordCount': '135,000',
        'coverUrl': null,
      },
      {
        'id': '3',
        'title': '哈姆雷特',
        'author': '威廉·莎士比亚',
        'category': '戏剧',
        'wordCount': '30,000',
        'coverUrl': null,
      },
    ];

    return books.where((book) {
      return book['title'].toString().contains(query) ||
          book['author'].toString().contains(query);
    }).toList();
  }

  // 执行搜索后仅更新名著结果
  void _updateBooksOnly(String query) {
    // 兼容旧逻辑：仍保留，但改为调用后端
    ApiClient().searchBooks(query).then((items) {
      final mapped = items.map((b) {
        final idStr = (b['id'] ?? '').toString();
        final numericId = int.tryParse(idStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return {
          'id': idStr,
          'numericId': numericId,
          'title': b['title'] ?? '',
          'author': b['author'] ?? '',
          'category': '小说',
          'wordCount': '?',
          'coverUrl': null,
          'description': b['description'] ?? '',
        };
      }).toList();
      setState(() {
        _searchResults['books'] = mapped;
        _isSearching = false;
      });
    }).catchError((_) {
      setState(() {
        _isSearching = false;
      });
    });
  }
}
