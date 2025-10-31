import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'analysis_repository.dart';
import '../../main.dart';
import 'analysis_detail_page.dart';

class LatestAnalysisPage extends StatefulWidget {
  const LatestAnalysisPage({super.key});

  @override
  State<LatestAnalysisPage> createState() => _LatestAnalysisPageState();
}

class _LatestAnalysisPageState extends State<LatestAnalysisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repo = AnalysisRepository();
  List<AnalysisItem> _all = [];
  String _query = '';
  Set<String> _liked = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final items = await _repo.listAllWithLikeOverrides();
    final liked = await _repo.loadLikedSet();
    setState(() {
      _all = items;
      _liked = liked;
    });
  }

  void _openPublishForm() async {
    final titleCtrl = TextEditingController();
    final bookCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final author = userProvider.username.isNotEmpty
        ? userProvider.username
        : '当前用户';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发布解析'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bookCtrl,
                decoration: const InputDecoration(
                  labelText: '作品名称',
                  hintText: '例如：傲慢与偏见',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: '解析标题',
                  hintText: '例如：人物关系解析',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: '解析正文',
                  hintText: '撰写你的解析内容...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleCtrl.text.trim();
              final book = bookCtrl.text.trim();
              final content = contentCtrl.text.trim();
              if (title.isEmpty || content.isEmpty || book.isEmpty) return;

              final item = AnalysisItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: title,
                content: content,
                author: author,
                bookTitle: book,
                publishDate: DateTime.now(),
                likeCount: 0,
              );
              final custom = await _repo.loadCustom();
              custom.insert(0, item);
              await _repo.saveCustom(custom);
              await _load();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('发布'),
          ),
        ],
      ),
    );
  }

  List<AnalysisItem> _filteredAll() {
    final q = _query.trim();
    final list = [..._all];
    if (q.isNotEmpty) {
      return list
          .where((e) => e.title.contains(q) || e.content.contains(q))
          .toList();
    }
    return list;
  }

  List<AnalysisItem> _hot() {
    final list = _filteredAll();
    list.sort((a, b) => b.likeCount.compareTo(a.likeCount));
    return list;
  }

  List<AnalysisItem> _mine() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final name = userProvider.username.isNotEmpty
        ? userProvider.username
        : '当前用户';
    return _filteredAll().where((e) => e.author == name).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('著作解析'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '全部解析'),
            Tab(text: '热门解析'),
            Tab(text: '我的发布'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.create),
            onPressed: _openPublishForm,
            tooltip: '撰写并发布解析',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '搜索解析…',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(_filteredAll()),
                _buildList(_hot()),
                _buildList(_mine()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openPublishForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(List<AnalysisItem> items) {
    if (items.isEmpty) {
      return const Center(child: Text('暂无解析内容'));
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final it = items[index];
        return ListTile(
          title: Text(
            '《${it.bookTitle}》${it.title.isNotEmpty ? '：${it.title}' : ''}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            it.content.length > 60
                ? '${it.content.substring(0, 60)}…'
                : it.content,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  _liked.contains(it.id)
                      ? Icons.thumb_up_alt
                      : Icons.thumb_up_alt_outlined,
                  size: 20,
                ),
                tooltip: _liked.contains(it.id) ? '取消赞' : '点赞',
                onPressed: () async {
                  await _repo.toggleLike(it.id);
                  await _load();
                },
              ),
              const SizedBox(width: 4),
              Text('${it.likeCount}'),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AnalysisDetailPage(item: it),
              ),
            );
          },
        );
      },
    );
  }
}