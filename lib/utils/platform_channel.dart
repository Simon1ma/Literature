import 'dart:async';
import 'package:flutter/services.dart';

/// 平台通道工具类，用于Flutter与Java原生功能的通信
class PlatformChannelUtil {
  static const MethodChannel _channel = MethodChannel(
    'com.example.english_reader/native',
  );

  /// 单例模式
  static final PlatformChannelUtil _instance = PlatformChannelUtil._internal();

  factory PlatformChannelUtil() {
    return _instance;
  }

  PlatformChannelUtil._internal();

  /// 从相册选择图片
  Future<String?> pickImage() async {
    try {
      final String? result = await _channel.invokeMethod('pickImage');
      return result;
    } on PlatformException catch (e) {
      print('Failed to pick image: ${e.message}');
      return null;
    }
  }

  /// 拍照获取图片
  Future<String?> takePhoto() async {
    try {
      final String? result = await _channel.invokeMethod('takePhoto');
      return result;
    } on PlatformException catch (e) {
      print('Failed to take photo: ${e.message}');
      return null;
    }
  }

  /// 保存文本到文件
  Future<String?> saveTextToFile(String text, String fileName) async {
    try {
      final Map<String, dynamic> args = {'text': text, 'fileName': fileName};
      final String? result = await _channel.invokeMethod(
        'saveTextToFile',
        args,
      );
      return result;
    } on PlatformException catch (e) {
      print('Failed to save text to file: ${e.message}');
      return null;
    }
  }

  /// 从文件读取文本
  Future<String?> readTextFromFile(String fileName) async {
    try {
      final Map<String, dynamic> args = {'fileName': fileName};
      final String? result = await _channel.invokeMethod(
        'readTextFromFile',
        args,
      );
      return result;
    } on PlatformException catch (e) {
      print('Failed to read text from file: ${e.message}');
      return null;
    }
  }

  /// 检查文件是否存在
  Future<bool> fileExists(String fileName) async {
    try {
      final Map<String, dynamic> args = {'fileName': fileName};
      final bool result = await _channel.invokeMethod('fileExists', args);
      return result;
    } on PlatformException catch (e) {
      print('Failed to check if file exists: ${e.message}');
      return false;
    }
  }

  /// 删除文件
  Future<bool> deleteFile(String fileName) async {
    try {
      final Map<String, dynamic> args = {'fileName': fileName};
      final bool result = await _channel.invokeMethod('deleteFile', args);
      return result;
    } on PlatformException catch (e) {
      print('Failed to delete file: ${e.message}');
      return false;
    }
  }

  /// 显示通知
  Future<void> showNotification(String title, String message) async {
    try {
      final Map<String, dynamic> args = {'title': title, 'message': message};
      await _channel.invokeMethod('showNotification', args);
    } on PlatformException catch (e) {
      print('Failed to show notification: ${e.message}');
    }
  }

  /// 显示带有大文本的通知
  Future<void> showBigTextNotification(
    String title,
    String message,
    String bigText,
  ) async {
    try {
      final Map<String, dynamic> args = {
        'title': title,
        'message': message,
        'bigText': bigText,
      };
      await _channel.invokeMethod('showBigTextNotification', args);
    } on PlatformException catch (e) {
      print('Failed to show big text notification: ${e.message}');
    }
  }

  /// 显示进度通知
  Future<void> showProgressNotification(
    String title,
    String message,
    int progress,
    int maxProgress,
  ) async {
    try {
      final Map<String, dynamic> args = {
        'title': title,
        'message': message,
        'progress': progress,
        'maxProgress': maxProgress,
      };
      await _channel.invokeMethod('showProgressNotification', args);
    } on PlatformException catch (e) {
      print('Failed to show progress notification: ${e.message}');
    }
  }

  /// 检查相机权限
  Future<bool> checkCameraPermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkCameraPermission');
      return result;
    } on PlatformException catch (e) {
      print('Failed to check camera permission: ${e.message}');
      return false;
    }
  }

  /// 请求相机权限
  Future<bool> requestCameraPermission() async {
    try {
      final bool result = await _channel.invokeMethod(
        'requestCameraPermission',
      );
      return result;
    } on PlatformException catch (e) {
      print('Failed to request camera permission: ${e.message}');
      return false;
    }
  }

  /// 检查存储权限
  Future<bool> checkStoragePermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkStoragePermission');
      return result;
    } on PlatformException catch (e) {
      print('Failed to check storage permission: ${e.message}');
      return false;
    }
  }

  /// 请求存储权限
  Future<bool> requestStoragePermission() async {
    try {
      final bool result = await _channel.invokeMethod(
        'requestStoragePermission',
      );
      return result;
    } on PlatformException catch (e) {
      print('Failed to request storage permission: ${e.message}');
      return false;
    }
  }

  /// 获取缓存大小
  Future<String> getCacheSize() async {
    try {
      final String result = await _channel.invokeMethod('getCacheSize');
      return result;
    } on PlatformException catch (e) {
      print('Failed to get cache size: ${e.message}');
      return '0 KB';
    }
  }

  /// 清除缓存
  Future<bool> clearCache() async {
    try {
      final bool result = await _channel.invokeMethod('clearCache');
      return result;
    } on PlatformException catch (e) {
      print('Failed to clear cache: ${e.message}');
      return false;
    }
  }
}
