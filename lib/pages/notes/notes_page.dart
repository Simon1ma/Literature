import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/api_client.dart';

class Note {
  final String id;
  final String bookId; // 例如 "b1"
  final String bookTitle; // 映射自后端图书
  final int chapterId; // 保留字段，暂无后端数据
  final String chapterTitle; // 保留字段，暂无后端数据
  final String selectedText; // 保留字段，暂无后端数据
  final String noteContent; // 映射自后端 content
  final DateTime createdAt;

  Note({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.chapterId,
    required this.chapterTitle,
    required this.selectedText,
    required this.noteContent,
    required this.createdAt,
  });
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedBook = '全部';
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];

  // 书籍列表（从后端加载）
  List<String> _books = ['全部'];
  Map<String, String> _bookIdToTitle = {}; // b1 -> Pride and Prejudice

  @override
  void initState() {
    super.initState();
    _loadNotes();

    _searchController.addListener(() {
      _filterNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 加载笔记数据
  void _loadNotes() async {
    try {
      // 加载图书用于显示标题与筛选
      final books = await ApiClient().searchBooks('');
      _bookIdToTitle = {
        for (final b in books)
          (b['id'] ?? '').toString(): (b['title'] ?? '').toString()
      };
      _books = ['全部', ...books.map((b) => (b['title'] ?? '').toString())];

      // 加载笔记
      final noteItems = await ApiClient().listNotes();
      final converted = noteItems.map((m) {
        final id = (m['id'] ?? '').toString();
        final bookId = (m['bookId'] ?? '').toString();
        final content = (m['content'] ?? '').toString();
        final createdAt = DateTime.tryParse((m['createdAt'] ?? '').toString()) ?? DateTime.now();
        final title = _bookIdToTitle[bookId] ?? bookId;
        return Note(
          id: id,
          bookId: bookId,
          bookTitle: title,
          chapterId: 0,
          chapterTitle: '',
          selectedText: '',
          noteContent: content,
          createdAt: createdAt,
        );
      }).toList();

      setState(() {
        _notes = converted;
        _filteredNotes = converted;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: '加载笔记失败：$e');
    }
  }

  // 筛选笔记
  void _filterNotes() {
    final searchText = _searchController.text.toLowerCase();
    final filteredByBook = _selectedBook == '全部'
        ? _notes
        : _notes.where((note) => note.bookTitle == _selectedBook).toList();

    setState(() {
      _filteredNotes = filteredByBook.where((note) {
        return note.noteContent.toLowerCase().contains(searchText) ||
            note.selectedText.toLowerCase().contains(searchText) ||
            note.chapterTitle.toLowerCase().contains(searchText);
      }).toList();
    });
  }

  // 编辑笔记
  void _editNote(Note note) {
    final noteController = TextEditingController(text: note.noteContent);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑笔记'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${note.bookTitle} - ${note.chapterTitle}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '原文: ${note.selectedText}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: '笔记内容',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newContent = noteController.text.trim();
              if (newContent.isEmpty) {
                Navigator.pop(context);
                return;
              }
              try {
                await ApiClient().updateNote(id: note.id, content: newContent);
                setState(() {
                  final idx = _notes.indexWhere((n) => n.id == note.id);
                  if (idx != -1) {
                    _notes[idx] = Note(
                      id: note.id,
                      bookId: note.bookId,
                      bookTitle: note.bookTitle,
                      chapterId: note.chapterId,
                      chapterTitle: note.chapterTitle,
                      selectedText: note.selectedText,
                      noteContent: newContent,
                      createdAt: note.createdAt,
                    );
                    _filterNotes();
                  }
                });
                Fluttertoast.showToast(msg: '笔记已更新');
              } catch (e) {
                Fluttertoast.showToast(msg: '更新失败：$e');
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // 删除笔记
  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除笔记'),
        content: const Text('确定要删除这条笔记吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              try {
                final ok = await ApiClient().deleteNote(id: note.id);
                if (ok) {
                  setState(() {
                    _notes.removeWhere((n) => n.id == note.id);
                    _filterNotes();
                  });
                  Fluttertoast.showToast(msg: '笔记已删除');
                } else {
                  Fluttertoast.showToast(msg: '删除失败');
                }
              } catch (e) {
                Fluttertoast.showToast(msg: '删除失败：$e');
              }
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的笔记')),
      body: Column(
        children: [
          // 搜索和筛选区域
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // 搜索框
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索笔记...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 书籍筛选下拉框
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                    ),
                    initialValue: _selectedBook,
                    items: _books.map((book) {
                      return DropdownMenuItem<String>(
                        value: book,
                        child: Text(book),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedBook = value;
                          _filterNotes();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // 笔记列表
          Expanded(
            child: _filteredNotes.isEmpty
                ? const Center(
                    child: Text(
                      '没有找到笔记',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = _filteredNotes[index];
                      return Dismissible(
                        key: Key('note_${note.id}'),
                        background: Container(
                          color: Colors.blue,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            // 删除操作
                            _deleteNote(note);
                            return false; // 不自动删除，等待对话框确认
                          } else {
                            // 编辑操作
                            _editNote(note);
                            return false; // 不自动删除
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 书籍和章节信息
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${note.bookTitle} - ${note.chapterTitle}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      '${note.createdAt.year}/${note.createdAt.month}/${note.createdAt.day}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // 原文
                                Text(
                                  '原文: ${note.selectedText}',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[800],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                // 笔记内容
                                Text(
                                  note.noteContent,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                // 操作按钮
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('编辑'),
                                      onPressed: () => _editNote(note),
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text('删除'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      onPressed: () => _deleteNote(note),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
