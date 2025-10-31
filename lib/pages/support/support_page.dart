import 'package:flutter/material.dart';
import '../../services/customer_service_api.dart';

enum MessageRole { user, assistant }

class _ChatMessage {
  final MessageRole role;
  final String text;
  _ChatMessage({required this.role, required this.text});
}

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final CustomerServiceApi _api = CustomerServiceApi();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // 初始客服欢迎语
    _messages.add(_ChatMessage(
      role: MessageRole.assistant,
      text: '欢迎使用客服助手，想问什么尽管说哦～',
    ));
  }

  Future<void> _handleSend() async {
    final content = _inputController.text.trim();
    if (content.isEmpty || _isSending) return;
    setState(() {
      _messages.add(_ChatMessage(role: MessageRole.user, text: content));
      _isSending = true;
    });
    _inputController.clear();
    try {
      final reply = await _api.getReply(content);
      setState(() {
        _messages.add(_ChatMessage(role: MessageRole.assistant, text: reply));
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Widget _buildBubble(_ChatMessage m) {
    final isUser = m.role == MessageRole.user;
    final bubbleColor = isUser
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade200;
    final textColor = isUser ? Colors.white : Colors.black87;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.support_agent, color: Colors.white, size: 18),
            ),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(left: isUser ? 0 : 8, right: isUser ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(m.text, style: TextStyle(color: textColor)),
            ),
          ),
          if (isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade400,
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('帮助与反馈')),
      body: Column(
        children: [
          // 对话区域
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildBubble(_messages[index]);
              },
            ),
          ),
          const Divider(height: 1),
          // 输入区域
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(
                        hintText: '请一句话描述您的问题',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (_) => _handleSend(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: _isSending ? null : _handleSend,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}