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

  // AI Analyze
  router.post('/ai/analyze', (Request req) async {
    try {
      final payload = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final text = (payload['text'] ?? '').toString();
      if (text.trim().isEmpty) {
        return Response(400, body: jsonEncode({'error': 'empty_text'}), headers: {'Content-Type': 'application/json'});
      }

      final provider = (Platform.environment['AI_PROVIDER'] ?? '').toLowerCase();
      if (provider == 'ollama') {
        final host = Platform.environment['OLLAMA_HOST'] ?? 'http://localhost:11434';
        final model = Platform.environment['OLLAMA_MODEL'] ?? 'qwen2:1.5b';
        final prompt = '''You are an assistant that returns STRICT JSON. Analyze the given text and respond ONLY with JSON in this schema:
{
  "summary": string,
  "sentiment": "positive" | "neutral" | "negative",
  "keywords": string[]
}
Text:
${text}
''';

        final client = HttpClient();
        final uri = Uri.parse('$host/api/generate');
        final req2 = await client.postUrl(uri);
        final body = jsonEncode({
          'model': model,
          'prompt': prompt,
          'stream': false,
        });
        req2.headers.contentType = ContentType('application', 'json', charset: 'utf-8');
        req2.add(utf8.encode(body));
        final resp2 = await req2.close();
        final respText = await resp2.transform(utf8.decoder).join();
        client.close(force: true);

        final decoded = jsonDecode(respText) as Map<String, dynamic>;
        final raw = (decoded['response'] ?? '').toString();

        Map<String, dynamic>? parsed;
        try {
          parsed = jsonDecode(raw) as Map<String, dynamic>;
        } catch (_) {
          // attempt to extract JSON block
          final start = raw.indexOf('{');
          final end = raw.lastIndexOf('}');
          if (start >= 0 && end > start) {
            final sub = raw.substring(start, end + 1);
            try {
              parsed = jsonDecode(sub) as Map<String, dynamic>;
            } catch (_) {}
          }
        }

        if (parsed == null) {
          // Fallback: minimal structure
          parsed = {
            'summary': raw.isNotEmpty ? raw.trim() : text.substring(0, text.length.clamp(0, 200)),
            'sentiment': 'neutral',
            'keywords': <String>[]
          };
        }
        return _okJson(parsed);
      } else if (provider == 'openai') {
        final apiKey = Platform.environment['OPENAI_API_KEY'] ?? '';
        if (apiKey.isEmpty) {
          return Response(400, body: jsonEncode({'error': 'missing_openai_key'}), headers: {'Content-Type': 'application/json'});
        }
        final client = HttpClient();
        final uri = Uri.parse('https://api.openai.com/v1/responses');
        final req2 = await client.postUrl(uri);
        req2.headers.set('Authorization', 'Bearer $apiKey');
        req2.headers.contentType = ContentType('application', 'json', charset: 'utf-8');
        final prompt = '''Return STRICT JSON only with keys: summary, sentiment (positive|neutral|negative), keywords (array). Text: ${text}''';
        final body = jsonEncode({
          'model': 'gpt-4o-mini',
          'input': prompt,
        });
        req2.add(utf8.encode(body));
        final resp2 = await req2.close();
        final respText = await resp2.transform(utf8.decoder).join();
        client.close(force: true);

        Map<String, dynamic>? parsed;
        try {
          final m = jsonDecode(respText) as Map<String, dynamic>;
          final out = (m['output'] ?? '').toString();
          parsed = jsonDecode(out) as Map<String, dynamic>;
        } catch (_) {}
        if (parsed == null) {
          parsed = {'error': 'invalid_model_response', 'raw': respText};
        }
        return _okJson(parsed);
      } else {
        return Response(400, body: jsonEncode({'error': 'invalid_provider'}), headers: {'Content-Type': 'application/json'});
      }
    } catch (e, st) {
      return Response.internalServerError(body: jsonEncode({'error': 'internal', 'message': e.toString()}), headers: {'Content-Type': 'application/json'});
    }
  });

  // AI Chat（多轮对话，优先使用 Ollama /api/chat）
  router.post('/ai/chat', (Request req) async {
    try {
      final payload = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final messages = (payload['messages'] as List?) ?? const [];
      final context = (payload['context'] as Map?) ?? const {};

      if (messages.isEmpty) {
        return Response(400, body: jsonEncode({'error': 'empty_messages'}), headers: {'Content-Type': 'application/json'});
      }

      final provider = (Platform.environment['AI_PROVIDER'] ?? '').toLowerCase();
      if (provider == 'ollama') {
        final host = Platform.environment['OLLAMA_HOST'] ?? 'http://localhost:11434';
        final model = Platform.environment['OLLAMA_MODEL'] ?? 'qwen2:1.5b';

        // 拼接系统提示，确保围绕选段与书名作答
        final sys = {
          'role': 'system',
          'content': 'You are a reading assistant. Answer concisely. If context is provided (selectedText, bookTitle), ground the answer in it. Reply in Chinese if user asks in Chinese. Otherwise reply in English.'
        };

        // 将选段上下文插入第一条用户消息之前（如果提供）
        final selectedText = (context['selectedText'] ?? '').toString();
        final bookTitle = (context['bookTitle'] ?? '').toString();
        final contextMsg = (selectedText.isNotEmpty || bookTitle.isNotEmpty)
            ? {
                'role': 'system',
                'content': 'Context:\nBook: ' + (bookTitle.isEmpty ? 'Unknown' : bookTitle) + '\nSelected: ' + (selectedText.isEmpty ? 'N/A' : selectedText)
              }
            : null;

        final finalMessages = [sys, if (contextMsg != null) contextMsg, ...messages];

        final client = HttpClient();
        final uri = Uri.parse('$host/api/chat');
        final req2 = await client.postUrl(uri);
        final body = jsonEncode({
          'model': model,
          'messages': finalMessages,
          'stream': false,
        });
        req2.headers.contentType = ContentType('application', 'json', charset: 'utf-8');
        req2.add(utf8.encode(body));
        final resp2 = await req2.close();
        final respText = await resp2.transform(utf8.decoder).join();
        client.close(force: true);

        final decoded = jsonDecode(respText) as Map<String, dynamic>;
        final reply = (decoded['message']?['content'] ?? decoded['response'] ?? '').toString();
        if (reply.isEmpty) {
          return _okJson({'reply': ''});
        }
        return _okJson({'reply': reply});
      } else if (provider == 'openai') {
        final apiKey = Platform.environment['OPENAI_API_KEY'] ?? '';
        if (apiKey.isEmpty) {
          return Response(400, body: jsonEncode({'error': 'missing_openai_key'}), headers: {'Content-Type': 'application/json'});
        }
        final client = HttpClient();
        final uri = Uri.parse('https://api.openai.com/v1/responses');
        final req2 = await client.postUrl(uri);
        req2.headers.set('Authorization', 'Bearer $apiKey');
        req2.headers.contentType = ContentType('application', 'json', charset: 'utf-8');
        final userText = (messages.last?['content'] ?? '').toString();
        final selectedText = (context['selectedText'] ?? '').toString();
        final bookTitle = (context['bookTitle'] ?? '').toString();
        final contextStr = 'Book: ${bookTitle}\nSelected: ${selectedText}';
        final prompt = 'Answer as a reading assistant. Context if any:\n$contextStr\nUser: $userText';
        final body = jsonEncode({
          'model': 'gpt-4o-mini',
          'input': prompt,
        });
        req2.add(utf8.encode(body));
        final resp2 = await req2.close();
        final respText = await resp2.transform(utf8.decoder).join();
        client.close(force: true);
        try {
          final m = jsonDecode(respText) as Map<String, dynamic>;
          final out = (m['output'] ?? '').toString();
          return _okJson({'reply': out});
        } catch (_) {
          return _okJson({'reply': respText});
        }
      } else {
        return Response(400, body: jsonEncode({'error': 'invalid_provider'}), headers: {'Content-Type': 'application/json'});
      }
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'internal', 'message': e.toString()}), headers: {'Content-Type': 'application/json'});
    }
  });

  final handler = const Pipeline().addMiddleware(logRequests()).addMiddleware(_cors()).addHandler(router);

  // 默认端口调整为 8090，便于与移动端调试一致
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8090;
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('Backend running on http://localhost:${server.port}');
}