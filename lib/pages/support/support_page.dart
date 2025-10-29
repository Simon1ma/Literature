import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  // 问题类型
  final List<String> _problemTypes = [
    '请选择问题类型',
    '账号问题',
    '阅读功能问题',
    '笔记功能问题',
    '解析内容问题',
    '讨论区问题',
    '应用崩溃',
    '其他问题',
  ];
  String _selectedProblemType = '请选择问题类型';

  // 反馈内容控制器
  final TextEditingController _feedbackController = TextEditingController();

  // 联系方式控制器
  final TextEditingController _contactController = TextEditingController();

  // 附件列表
  final List<String> _attachments = [];

  @override
  void dispose() {
    _feedbackController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  // 添加附件
  void _addAttachment() {
    // 实际应用中应调用原生Java方法选择文件
    // 这里模拟添加附件
    setState(() {
      _attachments.add('附件 ${_attachments.length + 1}');
    });

    Fluttertoast.showToast(msg: '已添加附件', toastLength: Toast.LENGTH_SHORT);
  }

  // 删除附件
  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  // 提交反馈
  void _submitFeedback() {
    // 表单验证
    if (_selectedProblemType == '请选择问题类型') {
      Fluttertoast.showToast(msg: '请选择问题类型', toastLength: Toast.LENGTH_SHORT);
      return;
    }

    if (_feedbackController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: '请填写反馈内容', toastLength: Toast.LENGTH_SHORT);
      return;
    }

    // 模拟提交反馈
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提交反馈'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在提交您的反馈...'),
          ],
        ),
      ),
    );

    // 模拟网络请求延迟
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);

      // 显示成功提示
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('提交成功'),
          content: const Text('感谢您的反馈，我们会尽快处理并回复您。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 清空表单
                setState(() {
                  _selectedProblemType = '请选择问题类型';
                  _feedbackController.clear();
                  _contactController.clear();
                  _attachments.clear();
                });
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('客服与反馈')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 客服联系方式
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '联系客服',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactItem(
                      icon: Icons.email,
                      title: '邮箱',
                      content: 'support@englishreader.com',
                    ),
                    const Divider(),
                    _buildContactItem(
                      icon: Icons.phone,
                      title: '电话',
                      content: '400-123-4567',
                    ),
                    const Divider(),
                    _buildContactItem(
                      icon: Icons.access_time,
                      title: '服务时间',
                      content: '周一至周五 9:00-18:00',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 常见问题
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '常见问题',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFaqItem(
                      question: '如何下载名著进行离线阅读？',
                      answer: '在名著详情页面，点击右上角的下载图标，即可将名著保存到本地进行离线阅读。',
                    ),
                    _buildFaqItem(
                      question: '如何修改账号密码？',
                      answer: '在"个人中心"页面，点击"账号安全"，然后选择"修改密码"即可。',
                    ),
                    _buildFaqItem(
                      question: '如何参与讨论？',
                      answer: '在"讨论区"页面，点击右下角的"+"按钮，即可发起新的讨论话题。',
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // 查看更多常见问题
                          Fluttertoast.showToast(
                            msg: '更多常见问题功能开发中...',
                            toastLength: Toast.LENGTH_SHORT,
                          );
                        },
                        child: const Text('查看更多常见问题'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 问题反馈表单
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '问题反馈',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 问题类型
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '问题类型',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _selectedProblemType,
                      items: _problemTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedProblemType = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // 反馈内容
                    TextField(
                      controller: _feedbackController,
                      decoration: const InputDecoration(
                        labelText: '反馈内容',
                        hintText: '请详细描述您遇到的问题...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    // 联系方式
                    TextField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: '联系方式（选填）',
                        hintText: '邮箱或手机号，方便我们回复您',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 附件
                    Row(
                      children: [
                        const Text('附件：'),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.attach_file),
                          label: const Text('添加附件'),
                          onPressed: _addAttachment,
                        ),
                      ],
                    ),
                    if (_attachments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          _attachments.length,
                          (index) => Chip(
                            label: Text(_attachments[index]),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeAttachment(index),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // 提交按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitFeedback,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('提交反馈'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // 构建联系方式项
  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(content, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  // 构建常见问题项
  Widget _buildFaqItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer),
        ),
      ],
    );
  }
}
