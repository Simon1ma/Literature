import 'dart:io';
import 'package:flutter/material.dart';
import 'package:english_reader/utils/platform_channel.dart';

class NativeFeaturesDemoPage extends StatefulWidget {
  const NativeFeaturesDemoPage({super.key});

  @override
  _NativeFeaturesDemoPageState createState() => _NativeFeaturesDemoPageState();
}

class _NativeFeaturesDemoPageState extends State<NativeFeaturesDemoPage> {
  final PlatformChannelUtil _platformChannel = PlatformChannelUtil();
  String _selectedImagePath = '';
  final String _noteContent = '';
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  String _fileContent = '';
  bool _hasCameraPermission = false;
  bool _hasStoragePermission = false;
  String _cacheSize = '0 KB';
  int _progressValue = 0;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _getCacheSize();
  }

  Future<void> _checkPermissions() async {
    final cameraPermission = await _platformChannel.checkCameraPermission();
    final storagePermission = await _platformChannel.checkStoragePermission();

    setState(() {
      _hasCameraPermission = cameraPermission;
      _hasStoragePermission = storagePermission;
    });
  }

  Future<void> _getCacheSize() async {
    final size = await _platformChannel.getCacheSize();
    setState(() {
      _cacheSize = size;
    });
  }

  Future<void> _pickImage() async {
    if (!_hasStoragePermission) {
      final granted = await _platformChannel.requestStoragePermission();
      if (!granted) {
        _showSnackBar('存储权限被拒绝，无法选择图片');
        return;
      }
      setState(() {
        _hasStoragePermission = granted;
      });
    }

    final imagePath = await _platformChannel.pickImage();
    if (imagePath != null) {
      setState(() {
        _selectedImagePath = imagePath;
      });
      _showSnackBar('已选择图片: $imagePath');
    }
  }

  Future<void> _takePhoto() async {
    if (!_hasCameraPermission) {
      final granted = await _platformChannel.requestCameraPermission();
      if (!granted) {
        _showSnackBar('相机权限被拒绝，无法拍照');
        return;
      }
      setState(() {
        _hasCameraPermission = granted;
      });
    }

    final imagePath = await _platformChannel.takePhoto();
    if (imagePath != null) {
      setState(() {
        _selectedImagePath = imagePath;
      });
      _showSnackBar('已拍摄照片: $imagePath');
    }
  }

  Future<void> _saveNote() async {
    if (_noteController.text.isEmpty || _fileNameController.text.isEmpty) {
      _showSnackBar('笔记内容和文件名不能为空');
      return;
    }

    final fileName = _fileNameController.text.endsWith('.txt')
        ? _fileNameController.text
        : '${_fileNameController.text}.txt';

    final filePath = await _platformChannel.saveTextToFile(
      _noteController.text,
      fileName,
    );

    if (filePath != null) {
      _showSnackBar('笔记已保存到: $filePath');
      _noteController.clear();
    } else {
      _showSnackBar('保存笔记失败');
    }
  }

  Future<void> _readNote() async {
    if (_fileNameController.text.isEmpty) {
      _showSnackBar('请输入要读取的文件名');
      return;
    }

    final fileName = _fileNameController.text.endsWith('.txt')
        ? _fileNameController.text
        : '${_fileNameController.text}.txt';

    final exists = await _platformChannel.fileExists(fileName);
    if (!exists) {
      _showSnackBar('文件不存在: $fileName');
      return;
    }

    final content = await _platformChannel.readTextFromFile(fileName);
    if (content != null) {
      setState(() {
        _fileContent = content;
      });
    } else {
      _showSnackBar('读取文件失败');
    }
  }

  Future<void> _deleteNote() async {
    if (_fileNameController.text.isEmpty) {
      _showSnackBar('请输入要删除的文件名');
      return;
    }

    final fileName = _fileNameController.text.endsWith('.txt')
        ? _fileNameController.text
        : '${_fileNameController.text}.txt';

    final exists = await _platformChannel.fileExists(fileName);
    if (!exists) {
      _showSnackBar('文件不存在: $fileName');
      return;
    }

    final success = await _platformChannel.deleteFile(fileName);
    if (success) {
      _showSnackBar('文件已删除: $fileName');
      setState(() {
        _fileContent = '';
      });
    } else {
      _showSnackBar('删除文件失败');
    }
  }

  void _showBasicNotification() {
    _platformChannel.showNotification('英语阅读器通知', '这是一条来自英语阅读器的基本通知');
    _showSnackBar('已发送基本通知');
  }

  void _showBigTextNotification() {
    _platformChannel.showBigTextNotification(
      '英语阅读器通知',
      '长文本通知',
      '这是一条来自英语阅读器的长文本通知。您可以在这里查看更多详细信息，例如新书推荐、阅读进度提醒或者学习建议等。',
    );
    _showSnackBar('已发送长文本通知');
  }

  void _showProgressNotification() {
    setState(() {
      _progressValue = 0;
    });

    // 模拟进度更新
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _progressValue += 10;
      });

      _platformChannel.showProgressNotification(
        '下载进度',
        '正在下载书籍...',
        _progressValue,
        100,
      );

      return _progressValue < 100;
    });

    _showSnackBar('已发送进度通知');
  }

  Future<void> _clearCache() async {
    final success = await _platformChannel.clearCache();
    if (success) {
      _showSnackBar('缓存已清除');
      _getCacheSize();
    } else {
      _showSnackBar('清除缓存失败');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('原生功能演示')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 权限状态卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '权限状态',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('相机权限: '),
                        Icon(
                          _hasCameraPermission
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _hasCameraPermission
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 16),
                        const Text('存储权限: '),
                        Icon(
                          _hasStoragePermission
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _hasStoragePermission
                              ? Colors.green
                              : Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 图片选择和拍照
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '图片功能',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('选择图片'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _takePhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('拍照'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_selectedImagePath.isNotEmpty)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _selectedImagePath.startsWith('http')
                            ? Image.network(
                                _selectedImagePath,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(_selectedImagePath),
                                fit: BoxFit.cover,
                              ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 文件操作
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '笔记功能',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _fileNameController,
                      decoration: const InputDecoration(
                        labelText: '文件名',
                        hintText: '输入文件名 (例如: my_note)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _noteController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: '笔记内容',
                        hintText: '在此输入笔记内容...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _saveNote,
                          icon: const Icon(Icons.save),
                          label: const Text('保存'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _readNote,
                          icon: const Icon(Icons.description),
                          label: const Text('读取'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _deleteNote,
                          icon: const Icon(Icons.delete),
                          label: const Text('删除'),
                        ),
                      ],
                    ),
                    if (_fileContent.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        '文件内容:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(_fileContent),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 通知功能
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '通知功能',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _showBasicNotification,
                          child: const Text('基本通知'),
                        ),
                        ElevatedButton(
                          onPressed: _showBigTextNotification,
                          child: const Text('长文本通知'),
                        ),
                        ElevatedButton(
                          onPressed: _showProgressNotification,
                          child: const Text('进度通知'),
                        ),
                      ],
                    ),
                    if (_progressValue > 0 && _progressValue < 100) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(value: _progressValue / 100),
                      const SizedBox(height: 8),
                      Text('进度: $_progressValue%'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 缓存管理
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '缓存管理',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('当前缓存大小: $_cacheSize'),
                        ElevatedButton.icon(
                          onPressed: _clearCache,
                          icon: const Icon(Icons.cleaning_services),
                          label: const Text('清除缓存'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
