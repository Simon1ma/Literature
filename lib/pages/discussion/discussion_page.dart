import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/api_client.dart';

class Topic {
  final int id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  int replyCount;
  int likeCount;
  bool isLiked;

  Topic({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    this.replyCount = 0,
    this.likeCount = 0,
    this.isLiked = false,
  });
}

class Reply {
  final int id;
  final int topicId;
  final String content;
  final String author;
  final DateTime createdAt;
  int likeCount;
  bool isLiked;

  Reply({
    required this.id,
    required this.topicId,
    required this.content,
    required this.author,
    required this.createdAt,
    this.likeCount = 0,
    this.isLiked = false,
  });
}

class DiscussionPage extends StatefulWidget {
  const DiscussionPage({super.key});

  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final Map<int, String> _topicIdMap = {};

  // 模拟话题数据
  final List<Topic> _topics = [
    Topic(
      id: 1,
      title: '《傲慢与偏见》中伊丽莎白的性格特点讨论',
      content: '大家觉得伊丽莎白最突出的性格特点是什么？她的独立思考能力和不盲从世俗的态度是否值得现代人学习？',
      author: '文学爱好者',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      replyCount: 15,
      likeCount: 24,
    ),
    Topic(
      id: 2,
      title: '简·奥斯汀作品中的女性观',
      content: '奥斯汀的小说中塑造了多种类型的女性形象，从伊丽莎白到简·艾尔，这些角色对当代女性主义文学有何影响？',
      author: '英文系学生',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      replyCount: 8,
      likeCount: 16,
    ),
    Topic(
      id: 3,
      title: '《双城记》中的历史背景与现实意义',
      content:
          '狄更斯在《双城记》中描绘的法国大革命场景给我留下了深刻印象。小说中"这是最好的时代，也是最坏的时代"的开篇名言至今仍有现实意义。大家怎么看？',
      author: '历史研究者',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      replyCount: 12,
      likeCount: 20,
    ),
    Topic(
      id: 4,
      title: '如何理解《远大前程》中的阶级流动？',
      content:
          '皮普从铁匠学徒到绅士的转变过程中，狄更斯似乎在批判维多利亚时代的阶级观念。大家认为这部小说对社会流动性的描述在当今社会仍有参考价值吗？',
      author: '社会学爱好者',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      replyCount: 6,
      likeCount: 13,
    ),
  ];

  // 模拟回复数据
  final Map<int, List<Reply>> _replies = {
    1: [
      Reply(
        id: 1,
        topicId: 1,
        content:
            '我认为伊丽莎白最突出的特点是她的独立思考能力。在当时的社会背景下，大多数女性都倾向于服从传统和家庭安排，而她却能够坚持自己的判断和选择。',
        author: '文学研究生',
        createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
        likeCount: 8,
      ),
      Reply(
        id: 2,
        topicId: 1,
        content:
            '我欣赏她的幽默感和机智。她能够用智慧和幽默来应对各种社交场合，特别是面对像柯林斯这样的人物时。这种特质使她在奥斯汀笔下的女性角色中显得格外生动。',
        author: '阅读爱好者',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        likeCount: 5,
      ),
      Reply(
        id: 3,
        topicId: 1,
        content:
            '我觉得她最可贵的是能够认识到自己的偏见并且改正。当她发现自己对达西的误解后，能够诚实面对并改变看法，这种自省能力在现代社会也非常重要。',
        author: '心理学学生',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
        likeCount: 10,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTopics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTopics({String query = ''}) async {
    try {
      final api = ApiClient();
      final items = await api.listDiscussions(query: query, sort: 'recent');
      final List<Topic> topics = [];
      final Map<int, String> idMap = {};
      for (var i = 0; i < items.length; i++) {
        final m = items[i];
        final id = i + 1; // 本地显示用递增ID
        idMap[id] = m['id'] as String;
        topics.add(Topic(
          id: id,
          title: (m['title'] ?? '') as String,
          content: (m['content'] ?? '') as String,
          author: (m['author'] ?? '') as String,
          createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
          replyCount: (m['replyCount'] ?? 0) as int,
          likeCount: (m['likeCount'] ?? 0) as int,
          isLiked: false,
        ));
      }
      setState(() {
        _topics
          ..clear()
          ..addAll(topics);
        _topicIdMap
          ..clear()
          ..addAll(idMap);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: '加载话题失败');
    }
  }

  // 创建新话题（接入后端）
  void _createNewTopic() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建新话题'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '话题标题',
                  hintText: '请输入话题标题（5-50字）',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: '话题内容',
                  hintText: '请输入话题内容（10-500字）',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                maxLength: 500,
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
              if (titleController.text.length < 5) {
                Fluttertoast.showToast(
                  msg: '标题至少需要5个字符',
                  toastLength: Toast.LENGTH_SHORT,
                );
                return;
              }
              if (contentController.text.length < 10) {
                Fluttertoast.showToast(
                  msg: '内容至少需要10个字符',
                  toastLength: Toast.LENGTH_SHORT,
                );
                return;
              }
              try {
                final api = ApiClient();
                final created = await api.createDiscussion(
                  title: titleController.text,
                  content: contentController.text,
                  author: '当前用户',
                );
                final idLocal = _topics.length + 1;
                setState(() {
                  _topicIdMap[idLocal] = created['id'] as String;
                  _topics.insert(
                    0,
                    Topic(
                      id: idLocal,
                      title: created['title'] ?? titleController.text,
                      content: created['content'] ?? contentController.text,
                      author: created['author'] ?? '当前用户',
                      createdAt: DateTime.tryParse(created['createdAt'] ?? '') ?? DateTime.now(),
                      replyCount: (created['replyCount'] ?? 0) as int,
                      likeCount: (created['likeCount'] ?? 0) as int,
                    ),
                  );
                });
              } catch (_) {
                Fluttertoast.showToast(msg: '发布失败');
                return;
              }
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: '话题发布成功',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
            child: const Text('发布'),
          ),
        ],
      ),
    );
  }

  // 查看话题详情
  void _viewTopicDetail(Topic topic) {
    final backendId = _topicIdMap[topic.id];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicDetailPage(
          topic: topic,
          backendTopicId: backendId,
          replies: _replies[topic.id] ?? [],
          onReplyAdded: (reply) {
            setState(() {
              if (_replies.containsKey(topic.id)) {
                _replies[topic.id]!.add(reply);
              } else {
                _replies[topic.id] = [reply];
              }
              topic.replyCount++;
            });
          },
          onLikeToggled: (isLiked) {
            setState(() {
              topic.isLiked = isLiked;
              topic.likeCount += isLiked ? 1 : -1;
            });
            if (backendId != null && backendId.isNotEmpty) {
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
      appBar: AppBar(
        title: const Text('讨论区'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '全部话题'),
            Tab(text: '热门讨论'),
            Tab(text: '我的话题'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索话题...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
              ),
            ),
          ),

          // 话题列表
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 全部话题
                _buildTopicList(_topics),

                // 热门讨论（按点赞数排序）
                _buildTopicList(
                  _topics..sort((a, b) => b.likeCount.compareTo(a.likeCount)),
                ),

                // 我的话题（实际应用中应该筛选当前用户的话题）
                _buildTopicList(
                  _topics.where((topic) => topic.author == '当前用户').toList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTopic,
        tooltip: '发布新话题',
        child: const Icon(Icons.add),
      ),
    );
  }

  // 构建话题列表
  Widget _buildTopicList(List<Topic> topics) {
    if (topics.isEmpty) {
      return const Center(
        child: Text('暂无话题', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: topics.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final topic = topics[index];
        return InkWell(
          onTap: () => _viewTopicDetail(topic),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(
                  topic.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // 内容预览
                Text(
                  topic.content,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // 作者和时间
                Row(
                  children: [
                    Text(
                      topic.author,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(topic.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    // 回复数
                    Row(
                      children: [
                        const Icon(Icons.comment, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${topic.replyCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // 点赞数
                    Row(
                      children: [
                        const Icon(
                          Icons.thumb_up,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${topic.likeCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 格式化日期
  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
    } else if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

// 话题详情页
class TopicDetailPage extends StatefulWidget {
  final Topic topic;
  final List<Reply> replies;
  final Function(Reply) onReplyAdded;
  final Function(bool) onLikeToggled;
  final String? backendTopicId;

  const TopicDetailPage({
    super.key,
    required this.topic,
    required this.replies,
    required this.onReplyAdded,
    required this.onLikeToggled,
    this.backendTopicId,
  });

  @override
  _TopicDetailPageState createState() => _TopicDetailPageState();
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  final TextEditingController _replyController = TextEditingController();
  List<Reply> _replies = [];
  late Topic _topic;

  @override
  void initState() {
    super.initState();
    _replies = List.from(widget.replies);
    _topic = widget.topic;
    _loadRepliesFromBackend();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadRepliesFromBackend() async {
    final id = widget.backendTopicId;
    if (id == null || id.isEmpty) return;
    try {
      final api = ApiClient();
      final items = await api.listDiscussionReplies(id);
      final List<Reply> fetched = [];
      for (var i = 0; i < items.length; i++) {
        final m = items[i];
        fetched.add(Reply(
          id: i + 1,
          topicId: _topic.id,
          content: (m['content'] ?? '') as String,
          author: (m['author'] ?? '') as String,
          createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
          likeCount: (m['likeCount'] ?? 0) as int,
        ));
      }
      setState(() {
        _replies
          ..clear()
          ..addAll(fetched);
      });
    } catch (_) {
      // 静默失败，保留本地数据
    }
  }

  // 添加回复
  void _addReply() {
    if (_replyController.text.isEmpty) {
      Fluttertoast.showToast(msg: '回复内容不能为空', toastLength: Toast.LENGTH_SHORT);
      return;
    }
    final backendId = widget.backendTopicId;
    if (backendId == null || backendId.isEmpty) {
      Fluttertoast.showToast(msg: '后端话题未关联');
      return;
    }
    ApiClient()
        .createDiscussionReply(id: backendId, content: _replyController.text, author: '当前用户')
        .then((created) {
      final newReply = Reply(
        id: _replies.isEmpty ? 1 : _replies.last.id + 1,
        topicId: _topic.id,
        content: (created['content'] ?? _replyController.text) as String,
        author: (created['author'] ?? '当前用户') as String,
        createdAt: DateTime.tryParse(created['createdAt'] ?? '') ?? DateTime.now(),
      );
      setState(() {
        _replies.add(newReply);
        _replyController.clear();
      });
      widget.onReplyAdded(newReply);
      Fluttertoast.showToast(msg: '回复成功', toastLength: Toast.LENGTH_SHORT);
    }).catchError((_) {
      Fluttertoast.showToast(msg: '回复失败');
    });
  }

  // 点赞话题
  void _likeTopic() {
    setState(() {
      _topic.isLiked = !_topic.isLiked;
      _topic.likeCount += _topic.isLiked ? 1 : -1;
    });

    widget.onLikeToggled(_topic.isLiked);
  }

  // 点赞回复
  void _likeReply(Reply reply) {
    setState(() {
      reply.isLiked = !reply.isLiked;
      reply.likeCount += reply.isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('话题详情')),
      body: Column(
        children: [
          // 话题内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 话题标题
                  Text(
                    _topic.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 作者和时间
                  Row(
                    children: [
                      Text(
                        _topic.author,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(_topic.createdAt),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 话题内容
                  Text(
                    _topic.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  // 点赞按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: Icon(
                          _topic.isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_outlined,
                          color: _topic.isLiked
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        label: Text(
                          '${_topic.likeCount}',
                          style: TextStyle(
                            color: _topic.isLiked
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                        ),
                        onPressed: _likeTopic,
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  // 回复标题
                  Text(
                    '全部回复 (${_replies.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 回复列表
                  ..._replies.map((reply) => _buildReplyItem(reply)),
                ],
              ),
            ),
          ),

          // 回复输入框
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: const InputDecoration(
                      hintText: '写下你的回复...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _addReply,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('回复'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建回复项
  Widget _buildReplyItem(Reply reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 作者和时间
          Row(
            children: [
              Text(
                reply.author,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(reply.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 回复内容
          Text(reply.content, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 8),
          // 点赞按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: Icon(
                  reply.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  size: 16,
                  color: reply.isLiked
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                label: Text(
                  '${reply.likeCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: reply.isLiked
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                onPressed: () => _likeReply(reply),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 格式化日期
  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
    } else if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
