import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  // 通知设置
  bool _pushNotifications = true;
  bool _emailNotifications = false;

  // 缓存大小
  String _cacheSize = '23.5 MB';

  // 应用版本
  final String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          // 账号安全
          _buildSectionHeader('账号安全'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('修改密码'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showChangePasswordDialog();
            },
          ),
          const Divider(),

          // 通知设置
          _buildSectionHeader('通知设置'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text('推送通知'),
            subtitle: const Text('接收新解析、讨论回复等推送通知'),
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
              Fluttertoast.showToast(
                msg: value ? '已开启推送通知' : '已关闭推送通知',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.email),
            title: const Text('邮件通知'),
            subtitle: const Text('接收每周学习摘要和重要更新'),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
              Fluttertoast.showToast(
                msg: value ? '已开启邮件通知' : '已关闭邮件通知',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
          ),
          const Divider(),

          // 界面设置
          _buildSectionHeader('界面设置'),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('应用主题'),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              underline: Container(),
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('跟随系统')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('浅色')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('深色')),
              ],
              onChanged: (ThemeMode? newThemeMode) {
                if (newThemeMode != null) {
                  themeProvider.toggleTheme();
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('阅读字体大小'),
            trailing: DropdownButton<String>(
              value: '中',
              underline: Container(),
              items: const [
                DropdownMenuItem(value: '小', child: Text('小')),
                DropdownMenuItem(value: '中', child: Text('中')),
                DropdownMenuItem(value: '大', child: Text('大')),
                DropdownMenuItem(value: '超大', child: Text('超大')),
              ],
              onChanged: (String? newSize) {
                if (newSize != null) {
                  Fluttertoast.showToast(
                    msg: '已设置字体大小为$newSize',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                }
              },
            ),
          ),
          const Divider(),

          // 存储管理
          _buildSectionHeader('存储管理'),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('缓存管理'),
            subtitle: Text('当前缓存大小：$_cacheSize'),
            trailing: TextButton(
              child: const Text('清除'),
              onPressed: () {
                _showClearCacheDialog();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('离线阅读设置'),
            subtitle: const Text('管理已下载的名著内容'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Fluttertoast.showToast(
                msg: '离线阅读设置功能开发中...',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
          ),
          const Divider(),

          // 关于
          _buildSectionHeader('关于'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于我们'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showAboutDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text('检查更新'),
            subtitle: Text('当前版本：$_appVersion'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _checkForUpdates();
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('隐私政策'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Fluttertoast.showToast(
                msg: '隐私政策功能开发中...',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('用户协议'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Fluttertoast.showToast(
                msg: '用户协议功能开发中...',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 构建分区标题
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // 修改密码对话框
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改密码'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: '当前密码',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: '新密码',
                  border: OutlineInputBorder(),
                  helperText: '密码至少包含8个字符，包括字母和数字',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: '确认新密码',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
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
            onPressed: () {
              // 验证密码
              final currentPassword = currentPasswordController.text;
              final newPassword = newPasswordController.text;
              final confirmPassword = confirmPasswordController.text;

              if (currentPassword.isEmpty ||
                  newPassword.isEmpty ||
                  confirmPassword.isEmpty) {
                Fluttertoast.showToast(
                  msg: '请填写所有密码字段',
                  toastLength: Toast.LENGTH_SHORT,
                );
                return;
              }

              if (newPassword != confirmPassword) {
                Fluttertoast.showToast(
                  msg: '两次输入的新密码不一致',
                  toastLength: Toast.LENGTH_SHORT,
                );
                return;
              }

              if (newPassword.length < 8) {
                Fluttertoast.showToast(
                  msg: '新密码长度不能少于8个字符',
                  toastLength: Toast.LENGTH_SHORT,
                );
                return;
              }

              // 模拟密码修改成功
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: '密码修改成功',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
            child: const Text('确认修改'),
          ),
        ],
      ),
    );
  }

  // 清除缓存对话框
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？这将删除临时文件，但不会影响您的个人数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 模拟清除缓存
              Navigator.pop(context);
              setState(() {
                _cacheSize = '0 B';
              });
              Fluttertoast.showToast(
                msg: '缓存已清除',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 关于对话框
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: '英语名著阅读解析',
        applicationVersion: _appVersion,
        applicationIcon: const FlutterLogo(size: 32),
        children: const [
          SizedBox(height: 16),
          Text(
            '英语名著阅读解析是一款面向学生和老师的英语名著学习平台，提供名著阅读、笔记添加、解析查看、讨论交流等功能。',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 16),
          Text('© 2023 英语名著阅读解析团队', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // 检查更新
  void _checkForUpdates() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('检查更新'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('正在检查更新...'),
          ],
        ),
      ),
    );

    // 模拟检查更新
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('检查更新'),
          content: const Text('您当前使用的已经是最新版本。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    });
  }
}
