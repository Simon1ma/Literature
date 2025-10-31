import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  static String _defaultBaseUrl() {
    // 可通过 --dart-define BASE_URL=... 覆盖
    const defined = String.fromEnvironment('BASE_URL');
    if (defined.isNotEmpty) return defined;
    // Android模拟器默认使用 10.0.2.2 访问宿主机；实体机建议使用 adb reverse 并指定 BASE_URL=http://localhost:8090
    if (Platform.isAndroid) return 'http://10.0.2.2:8090';
    return 'http://localhost:8090';
  }

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: _defaultBaseUrl(),
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    // 读取此前保存的自定义后端地址（用于真机调试）
    SharedPreferences.getInstance().then((prefs) async {
      final saved = prefs.getString('apiBaseUrl');
      if (saved != null && saved.isNotEmpty) {
        dio.options.baseUrl = saved;
        return;
      }
      // Android真机场景：若 10.0.2.2 不可达，则尝试 localhost（配合 adb reverse）
      if (Platform.isAndroid) {
        try {
          await dio.get('/health');
        } catch (_) {
          dio.options.baseUrl = 'http://localhost:8090';
        }
      }
    });

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 添加 Authorization
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('authToken');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) {
        handler.next(e);
      },
    ));
  }

  // 允许在真机上设置后端地址（如 192.168.x.x:8090）
  Future<void> configureBaseUrl(String url) async {
    dio.options.baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiBaseUrl', url);
  }

  // Auth
  Future<String?> login({required String email, required String password}) async {
    final resp = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final token = resp.data['token'] as String?;
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
    }
    return token;
  }

  Future<Map<String, dynamic>> register({required String email, required String password, required String name}) async {
    final resp = await dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'name': name,
    });
    return Map<String, dynamic>.from(resp.data as Map);
  }

  Future<Map<String, dynamic>?> me() async {
    try {
      final resp = await dio.get('/profile/me');
      return Map<String, dynamic>.from(resp.data as Map);
    } on DioException catch (_) {
      return null;
    }
  }

  // Books
  Future<List<Map<String, dynamic>>> searchBooks(String query) async {
    final resp = await dio.get('/books', queryParameters: {'query': query});
    final items = (resp.data['items'] as List?) ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  // Notes
  Future<Map<String, dynamic>> createNote({required String bookId, required String content}) async {
    final resp = await dio.post('/notes', data: {
      'bookId': bookId,
      'content': content,
    });
    return Map<String, dynamic>.from(resp.data as Map);
  }

  Future<List<Map<String, dynamic>>> listNotes({String? bookId}) async {
    final resp = await dio.get('/notes', queryParameters: {
      if (bookId != null && bookId.isNotEmpty) 'bookId': bookId,
    });
    final items = (resp.data['items'] as List?) ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> updateNote({required String id, required String content}) async {
    final resp = await dio.put('/notes/$id', data: {
      'content': content,
    });
    return Map<String, dynamic>.from(resp.data as Map);
  }

  Future<bool> deleteNote({required String id}) async {
    final resp = await dio.delete('/notes/$id');
    final m = Map<String, dynamic>.from(resp.data as Map);
    return (m['success'] as bool?) ?? false;
  }

  // Discussions
  Future<List<Map<String, dynamic>>> listDiscussions({String? query, String? sort}) async {
    final resp = await dio.get('/discussions', queryParameters: {
      if (query != null && query.isNotEmpty) 'query': query,
      if (sort != null && sort.isNotEmpty) 'sort': sort,
    });
    final items = (resp.data['items'] as List?) ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> getDiscussion(String id) async {
    try {
      final resp = await dio.get('/discussions/$id');
      return Map<String, dynamic>.from(resp.data as Map);
    } on DioException catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> listDiscussionReplies(String id) async {
    final resp = await dio.get('/discussions/$id/replies');
    final items = (resp.data['items'] as List?) ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createDiscussion({required String title, required String content, required String author}) async {
    final resp = await dio.post('/discussions', data: {
      'title': title,
      'content': content,
      'author': author,
    });
    return Map<String, dynamic>.from(resp.data as Map);
  }

  Future<Map<String, dynamic>> createDiscussionReply({required String id, required String content, required String author}) async {
    final resp = await dio.post('/discussions/$id/replies', data: {
      'content': content,
      'author': author,
    });
    return Map<String, dynamic>.from(resp.data as Map);
  }

  Future<Map<String, dynamic>?> likeDiscussion({required String id, required bool like}) async {
    try {
      final resp = await dio.post('/discussions/$id/like', data: {
        'like': like,
      });
      return Map<String, dynamic>.from(resp.data as Map);
    } on DioException catch (_) {
      return null;
    }
  }
}