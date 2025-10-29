import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Note {
  final int id;
  final int bookId;
  final String bookTitle;
  final int chapterId;
  final String chapterTitle;
  final String selectedText;
  final String noteContent;
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

  // 模拟书籍列表
  final List<String> _books = ['全部', '傲慢与偏见', '简爱', '双城记', '远大前程', '雾都孤儿'];

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
  void _loadNotes() {
    // 模拟从Hive加载笔记数据
    final mockNotes = [
      Note(
        id: 1,
        bookId: 1,
        bookTitle: '傲慢与偏见',
        chapterId: 1,
        chapterTitle: '第一章',
        selectedText:
            'It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife.',
        noteContent: '这是小说的开篇句，讽刺了当时社会对婚姻的功利态度。',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Note(
        id: 2,
        bookId: 1,
        bookTitle: '傲慢与偏见',
        chapterId: 3,
        chapterTitle: '第三章',
        selectedText: 'She is tolerable, but not handsome enough to tempt me.',
        noteContent: '达西对伊丽莎白的第一印象，展现了他的傲慢性格。',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Note(
        id: 3,
        bookId: 2,
        bookTitle: '简爱',
        chapterId: 2,
        chapterTitle: '第二章',
        selectedText:
            'I am no bird; and no net ensnares me; I am a free human being with an independent will.',
        noteContent: '简爱表达对自由和独立的渴望，体现了小说的女性主义思想。',
        createdAt: DateTime.now(),
      ),
    ];

    setState(() {
      _notes = mockNotes;
      _filteredNotes = mockNotes;
    });
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
            onPressed: () {
              // 更新笔记逻辑
              if (noteController.text.isNotEmpty) {
                // 这里应该更新Hive中的笔记
                Fluttertoast.showToast(
                  msg: '笔记已更新',
                  toastLength: Toast.LENGTH_SHORT,
                );
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
            onPressed: () {
              // 删除笔记逻辑
              setState(() {
                _notes.removeWhere((n) => n.id == note.id);
                _filterNotes();
              });
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: '笔记已删除',
                toastLength: Toast.LENGTH_SHORT,
              );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 跳转到阅读页面添加新笔记
          Fluttertoast.showToast(
            msg: '请在阅读页面选中文本添加笔记',
            toastLength: Toast.LENGTH_LONG,
          );
        },
        tooltip: '添加笔记',
        child: const Icon(Icons.add),
      ),
    );
  }
}
