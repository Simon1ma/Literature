import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../main.dart';

class BookReaderPage extends StatefulWidget {
  final int bookId;
  final String bookTitle;

  const BookReaderPage({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  @override
  _BookReaderPageState createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  int _currentChapter = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isNightMode = false;
  double _fontSize = 16.0;

  // 模拟章节数据
  final List<String> _chapters = [
    '第一章',
    '第二章',
    '第三章',
    '第四章',
    '第五章',
    '第六章',
    '第七章',
    '第八章',
    '第九章',
    '第十章',
  ];

  // 模拟章节内容
  final Map<int, String> _chapterContents = {
    0: '''It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife.

However little known the feelings or views of such a man may be on his first entering a neighbourhood, this truth is so well fixed in the minds of the surrounding families, that he is considered the rightful property of some one or other of their daughters.

"My dear Mr. Bennet," said his lady to him one day, "have you heard that Netherfield Park is let at last?"

Mr. Bennet replied that he had not.

"But it is," returned she; "for Mrs. Long has just been here, and she told me all about it."

Mr. Bennet made no answer.

"Do you not want to know who has taken it?" cried his wife impatiently.

"You want to tell me, and I have no objection to hearing it."

This was invitation enough.

"Why, my dear, you must know, Mrs. Long says that Netherfield is taken by a young man of large fortune from the north of England; that he came down on Monday in a chaise and four to see the place, and was so much delighted with it, that he agreed with Mr. Morris immediately; that he is to take possession before Michaelmas, and some of his servants are to be in the house by the end of next week."

"What is his name?"

"Bingley."

"Is he married or single?"

"Oh! Single, my dear, to be sure! A single man of large fortune; four or five thousand a year. What a fine thing for our girls!"

"How so? How can it affect them?"

"My dear Mr. Bennet," replied his wife, "how can you be so tiresome! You must know that I am thinking of his marrying one of them."

"Is that his design in settling here?"

"Design! Nonsense, how can you talk so! But it is very likely that he may fall in love with one of them, and therefore you must visit him as soon as he comes."''',
    1: '''Mr. Bennet was among the earliest of those who waited on Mr. Bingley. He had always intended to visit him, though to the last always assuring his wife that he should not go; and till the evening after the visit was paid she had no knowledge of it. It was then disclosed in the following manner. Observing his second daughter employed in trimming a hat, he suddenly addressed her with:

"I hope Mr. Bingley will like it, Lizzy."

"We are not in a way to know what Mr. Bingley likes," said her mother resentfully, "since we are not to visit."

"But you forget, mamma," said Elizabeth, "that we shall meet him at the assemblies, and that Mrs. Long promised to introduce him."

"I do not believe Mrs. Long will do any such thing. She has two nieces of her own. She is a selfish, hypocritical woman, and I have no opinion of her."

"No more have I," said Mr. Bennet; "and I am glad to find that you do not depend on her serving you."

Mrs. Bennet deigned not to make any reply, but, unable to contain herself, began scolding one of her daughters.

"Don't keep coughing so, Kitty, for Heaven's sake! Have a little compassion on my nerves. You tear them to pieces."

"Kitty has no discretion in her coughs," said her father; "she times them ill."

"I do not cough for my own amusement," replied Kitty fretfully. "When is your next ball to be, Lizzy?"

"To-morrow fortnight."

"Aye, so it is," cried her mother, "and Mrs. Long does not come back till the day before; so it will be impossible for her to introduce him, for she will not know him herself."

"Then, my dear, you may have the advantage of your friend, and introduce Mr. Bingley to her."

"Impossible, Mr. Bennet, impossible, when I am not acquainted with him myself; how can you be so teasing?"

"I honour your circumspection. A fortnight's acquaintance is certainly very little. One cannot know what a man really is by the end of a fortnight. But if we do not venture somebody else will; and after all, Mrs. Long and her nieces must stand their chance; and, therefore, as she will think it an act of kindness, if you decline the office, I will take it on myself."''',
  };

  @override
  void initState() {
    super.initState();
    _loadReaderSettings();
    _loadLastReadPosition();

    // 监听滚动位置，保存阅读进度
    _scrollController.addListener(_saveScrollPosition);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_saveScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  // 加载阅读设置
  void _loadReaderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isNightMode = prefs.getBool('isNightMode') ?? false;
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    });
  }

  // 保存阅读设置
  void _saveReaderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNightMode', _isNightMode);
    await prefs.setDouble('fontSize', _fontSize);
  }

  // 加载上次阅读位置
  void _loadLastReadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final bookKey = 'book_${widget.bookId}';
    setState(() {
      _currentChapter = prefs.getInt('${bookKey}_chapter') ?? 0;

      // 延迟滚动到上次位置
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          final position = prefs.getDouble('${bookKey}_position') ?? 0.0;
          _scrollController.jumpTo(
            position.clamp(0.0, _scrollController.position.maxScrollExtent),
          );
        }
      });
    });
  }

  // 保存滚动位置
  void _saveScrollPosition() async {
    if (!_scrollController.hasClients) return;

    final prefs = await SharedPreferences.getInstance();
    final bookKey = 'book_${widget.bookId}';
    await prefs.setInt('${bookKey}_chapter', _currentChapter);
    await prefs.setDouble('${bookKey}_position', _scrollController.offset);
  }

  // 切换章节
  void _changeChapter(int chapter) {
    setState(() {
      _currentChapter = chapter;
      // 重置滚动位置
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    });
    Navigator.pop(context); // 关闭抽屉
  }

  // 添加笔记
  void _addNote(String selectedText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final noteController = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '添加笔记',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '选中文本: $selectedText',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  hintText: '输入笔记内容...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // 保存笔记逻辑
                      if (noteController.text.isNotEmpty) {
                        // 这里应该将笔记保存到Hive或其他存储
                        Fluttertoast.showToast(
                          msg: '笔记已保存',
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('保存'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final readerProvider = Provider.of<ReaderProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return WillPopScope(
      onWillPop: _handleWillPopToHome,
      child: Scaffold(
      appBar: AppBar(
        title: Text(widget.bookTitle),
        backgroundColor: _isNightMode
            ? Colors.black
            : Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.format_size),
            onPressed: _showFontSizeDialog,
          ),
          IconButton(
            icon: Icon(_isNightMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () {
              setState(() {
                _isNightMode = !_isNightMode;
                _saveReaderSettings();
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: _isNightMode
                    ? Colors.black
                    : Theme.of(context).colorScheme.primary,
              ),
              child: Center(
                child: Text(
                  widget.bookTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _chapters.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_chapters[index]),
                    selected: _currentChapter == index,
                    selectedTileColor: (_isNightMode
                        ? Colors.grey[800]
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1)),
                    onTap: () => _changeChapter(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          // 在平板模式下显示左侧章节导航
          if (isTablet)
            Container(
              width: 200,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: _isNightMode ? Colors.grey[800]! : Colors.grey[300]!,
                  ),
                ),
              ),
              child: ListView.builder(
                itemCount: _chapters.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_chapters[index]),
                    selected: _currentChapter == index,
                    selectedTileColor: (_isNightMode
                        ? Colors.grey[800]
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1)),
                    onTap: () => setState(() {
                      _currentChapter = index;
                      // 重置滚动位置
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(0);
                        }
                      });
                    }),
                  );
                },
              ),
            ),

          // 阅读区域
          Expanded(
            child: Container(
              color: _isNightMode ? Colors.black : Colors.white,
              child: GestureDetector(
                onLongPress: () {
                  // 长按选中文本的处理
                  // 这里简化处理，实际应该获取用户选中的文本
                  final selectedText = "用户选中的文本示例";
                  _showTextSelectionMenu(selectedText);
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _chapterContents[_currentChapter] ?? '本章内容加载中...',
                    style: TextStyle(
                      fontSize: _fontSize,
                      height: 1.5,
                      color: _isNightMode ? Colors.grey[300] : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  // 显示字体大小调整对话框
  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('调整字体大小'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('预览文本', style: TextStyle(fontSize: _fontSize)),
                const SizedBox(height: 16),
                Slider(
                  value: _fontSize,
                  min: 12.0,
                  max: 24.0,
                  divisions: 6,
                  label: _fontSize.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _fontSize = value;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // 已在StatefulBuilder中更新了_fontSize
                _saveReaderSettings();
              });
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 显示文本选择菜单
  void _showTextSelectionMenu(String selectedText) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.note_add),
            title: const Text('添加笔记'),
            onTap: () {
              Navigator.pop(context);
              _addNote(selectedText);
            },
          ),
          ListTile(
            leading: const Icon(Icons.highlight),
            title: const Text('高亮标记'),
            onTap: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: '已添加高亮标记',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: const Text('查看翻译'),
            onTap: () {
              Navigator.pop(context);
              // 显示翻译结果
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('翻译'),
                  content: Text('$selectedText\n\n这是翻译后的文本示例'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.content_copy),
            title: const Text('复制'),
            onTap: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: '已复制到剪贴板',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
          ),
        ],
      ),
    );
  }

  // 处理安卓系统返回键，统一返回到主页
  Future<bool> _handleWillPopToHome() async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    return false; // 阻止默认行为（避免重复 pop）
  }
}
