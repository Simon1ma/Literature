import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/api_client.dart';
import '../discussion/discussion_page.dart';

class MyDiscussionsPage extends StatefulWidget {
  const MyDiscussionsPage({super.key});

  @override
  State<MyDiscussionsPage> createState() => _MyDiscussionsPageState();
}

class _MyDiscussionsPageState extends State<MyDiscussionsPage> {
  List<Map<String, dynamic>> _topics = [];
  bool _loading = true;
  final String _username = '文学爱好者';

  @override
  void initState() {
    super.initState();
    _loadMyTopics();
  }

  Future<void> _loadMyTopics() async {
    setState(() => _loading = true);
    try {
      final api = ApiClient();
      final items = await api.listDiscussions(sort: 'recent');
      final mine = items.where((m) => (m['author'] ?? '') == _username).toList();
      mine.sort((a, b) => (b['createdAt'] ?? '').toString().compareTo((a['createdAt'] ?? '').toString()));
      setState(() {
        _topics = mine;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
      Fluttertoast.showToast(msg: '加载我的讨论失败');
    }
  }

  void _openTopic(Map<String, dynamic> m, int idx) {
    final backendId = (m['id'] ?? '').toString();
    final topic = Topic(
      id: idx + 1,
      title: (m['title'] ?? '') as String,
      content: (m['content'] ?? '') as String,
      author: (m['author'] ?? '') as String,
      createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
      replyCount: (m['replyCount'] ?? 0) as int,
      likeCount: (m['likeCount'] ?? 0) as int,
      isLiked: false,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TopicDetailPage(
          topic: topic,
          backendTopicId: backendId,
          replies: const [],
          onReplyAdded: (reply) {
            setState(() {
              _topics[idx]['replyCount'] = (_topics[idx]['replyCount'] ?? 0) + 1;
            });
          },
          onLikeToggled: (isLiked) {
            setState(() {
              final cur = (_topics[idx]['likeCount'] ?? 0) as int;
              _topics[idx]['likeCount'] = cur + (isLiked ? 1 : -1);
            });
            if (backendId.isNotEmpty) {
              ApiClient().likeDiscussion(id: backendId, like: isLiked);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的讨论')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _topics.isEmpty
              ? const Center(child: Text('你还没有发布讨论'))
              : ListView.builder(
                  itemCount: _topics.length,
                  itemBuilder: (context, index) {
                    final m = _topics[index];
                    return ListTile(
                      leading: const Icon(Icons.forum, color: Colors.blueAccent),
                      title: Text(m['title'] ?? ''),
                      subtitle: Text(
                        m['content'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('👍 ${m['likeCount'] ?? 0} · 💬 ${m['replyCount'] ?? 0}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      onTap: () => _openTopic(m, index),
                    );
                  },
                ),
    );
  }
}