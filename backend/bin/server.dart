import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import '../lib/storage.dart';
import '../lib/models.dart';

Middleware _cors() {
  return (Handler innerHandler) {
    return (Request req) async {
      final resp = await innerHandler(req);
      return resp.change(headers: {
        ...resp.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      });
    };
  };
}

Response _okJson(Object body) => Response.ok(jsonEncode(body), headers: {
      'Content-Type': 'application/json; charset=utf-8'
    });

Future<void> main(List<String> args) async {
  final dataDir = Directory('backend/data');
  if (!await dataDir.exists()) {
    await dataDir.create(recursive: true);
  }
  final store = JsonStore(dataDir.path);
  await store.init();

  final router = Router();

  // Health
  router.get('/health', (Request req) => _okJson({'status': 'ok'}));

  // Auth
  router.post('/auth/register', (Request req) async {
    final payload = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final user = await store.register(payload['email'], payload['password'], payload['name'] ?? '');
    return _okJson(user.toJson());
  });

  router.post('/auth/login', (Request req) async {
    final payload = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final token = await store.login(payload['email'], payload['password']);
    if (token == null) return Response.forbidden(jsonEncode({'error': 'invalid_credentials'}), headers: {'Content-Type': 'application/json'});
    return _okJson({'token': token});
  });

  // Profile
  router.get('/profile/me', (Request req) async {
    final token = req.headers['authorization']?.replaceFirst('Bearer ', '') ?? '';
    final user = await store.getUserByToken(token);
    if (user == null) return Response.forbidden(jsonEncode({'error': 'unauthorized'}), headers: {'Content-Type': 'application/json'});
    return _okJson(user.toJson());
  });

  // Books
  router.get('/books', (Request req) async {
    final q = req.requestedUri.queryParameters['query']?.toLowerCase() ?? '';
    final books = await store.listBooks(query: q);
    return _okJson({'items': books.map((b) => b.toJson()).toList()});
  });

  router.get('/books/<id>', (Request req, String id) async {
    final book = await store.getBook(id);
    if (book == null) return Response.notFound(jsonEncode({'error': 'not_found'}), headers: {'Content-Type': 'application/json'});
    return _okJson(book.toJson());
  });

  // Notes
  router.get('/notes', (Request req) async {
    final bookId = req.requestedUri.queryParameters['bookId'];
    final items = await store.listNotes(bookId: bookId);
    return _okJson({'items': items.map((n) => n.toJson()).toList()});
  });

  router.post('/notes', (Request req) async {
    final payload = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final note = await store.createNote(payload['bookId'], payload['content'] ?? '');
    return _okJson(note.toJson());
  });

  router.put('/notes/<id>', (Request req, String id) async {
    final payload = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final note = await store.updateNote(id, payload['content'] ?? '');
    if (note == null) return Response.notFound(jsonEncode({'error': 'not_found'}), headers: {'Content-Type': 'application/json'});
    return _okJson(note.toJson());
  });

  router.delete('/notes/<id>', (Request req, String id) async {
    final ok = await store.deleteNote(id);
    return _okJson({'success': ok});
  });

  // Discussions
  router.get('/discussions', (Request req) async {
    final q = req.requestedUri.queryParameters['query'] ?? '';
    final sort = req.requestedUri.queryParameters['sort']; // likes | recent
    final topics = await store.listTopics(query: q, sort: sort);
    return _okJson({'items': topics.map((t) => t.toJson()).toList()});
  });

  router.get('/discussions/<id>', (Request req, String id) async {
    final t = await store.getTopic(id);
    if (t == null) return Response.notFound(jsonEncode({'error': 'not_found'}), headers: {'Content-Type': 'application/json'});
    return _okJson(t.toJson());
  });

  router.get('/discussions/<id>/replies', (Request req, String id) async {
    final replies = await store.listReplies(id);
    return _okJson({'items': replies.map((r) => r.toJson()).toList()});
  });

  router.post('/discussions', (Request req) async {
    final payload = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final t = await store.createTopic(payload['title'] ?? '', payload['content'] ?? '', payload['author'] ?? '匿名');
    return _okJson(t.toJson());
  });

  router.post('/discussions/<id>/replies', (Request req, String id) async {
    final payload = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final r = await store.createReply(id, payload['content'] ?? '', payload['author'] ?? '匿名');
    return _okJson(r.toJson());
  });

  router.post('/discussions/<id>/like', (Request req, String id) async {
    final payload = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final like = payload['like'] == true;
    final t = await store.likeTopic(id, like ? 1 : -1);
    if (t == null) return Response.notFound(jsonEncode({'error': 'not_found'}), headers: {'Content-Type': 'application/json'});
    return _okJson(t.toJson());
  });

  final handler = const Pipeline().addMiddleware(logRequests()).addMiddleware(_cors()).addHandler(router);

  // 默认端口调整为 8090，便于与移动端调试一致
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8090;
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('Backend running on http://localhost:${server.port}');
}