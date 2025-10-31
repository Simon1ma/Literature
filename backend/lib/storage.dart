import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

import 'models.dart';

class JsonStore {
  final String baseDir;
  late final File usersFile;
  late final File booksFile;
  late final File notesFile;
  late final File discussionsFile;
  final _uuid = const Uuid();

  JsonStore(this.baseDir);

  Future<void> init() async {
    usersFile = File('$baseDir/users.json');
    booksFile = File('$baseDir/books.json');
    notesFile = File('$baseDir/notes.json');
    discussionsFile = File('$baseDir/discussions.json');
    if (!await usersFile.exists()) {
      await usersFile.writeAsString(jsonEncode({'users': [], 'sessions': {}}));
    }
    if (!await booksFile.exists()) {
      final sample = [
        Book(id: 'b1', title: 'Pride and Prejudice', author: 'Jane Austen', description: 'A classic novel about manners and matrimony.'),
        Book(id: 'b2', title: 'Great Expectations', author: 'Charles Dickens', description: 'Pip’s coming-of-age journey and social critique.'),
        Book(id: 'b3', title: 'Moby-Dick', author: 'Herman Melville', description: 'The pursuit of the white whale and obsession.'),
      ];
      await booksFile.writeAsString(jsonEncode({'books': sample.map((e) => e.toJson()).toList()}));
    }
    if (!await notesFile.exists()) {
      await notesFile.writeAsString(jsonEncode({'notes': []}));
    }
    if (!await discussionsFile.exists()) {
      final topics = [
        {
          'id': _uuid.v4(),
          'title': '《傲慢与偏见》最打动你的片段',
          'content': '分享一下最打动你的情节，以及原因。',
          'author': '文学爱好者',
          'createdAt': DateTime.now().toIso8601String(),
          'replyCount': 0,
          'likeCount': 3,
        },
        {
          'id': _uuid.v4(),
          'title': '《双城记》的现实意义',
          'content': '从历史与现实两方面聊聊这部作品。',
          'author': '历史研究者',
          'createdAt': DateTime.now().toIso8601String(),
          'replyCount': 0,
          'likeCount': 1,
        },
      ];
      await discussionsFile.writeAsString(jsonEncode({'topics': topics, 'replies': []}));
    }
  }

  // Helpers
  Future<Map<String, dynamic>> _readJson(File f) async {
    final s = await f.readAsString();
    return jsonDecode(s) as Map<String, dynamic>;
  }

  Future<void> _writeJson(File f, Map<String, dynamic> data) async {
    final encoder = const JsonEncoder.withIndent('  ');
    await f.writeAsString(encoder.convert(data));
  }

  // Discussions
  Future<List<DiscussionTopic>> listTopics({String query = '', String? sort}) async {
    final data = await _readJson(discussionsFile);
    var topics = (data['topics'] as List).cast<Map<String, dynamic>>()
        .map((m) => DiscussionTopic.fromMap(m))
        .toList();
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      topics = topics.where((t) => t.title.toLowerCase().contains(q) || t.content.toLowerCase().contains(q)).toList();
    }
    if (sort == 'likes') {
      topics.sort((a, b) => b.likeCount.compareTo(a.likeCount));
    } else if (sort == 'recent') {
      topics.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return topics;
  }

  Future<DiscussionTopic?> getTopic(String id) async {
    final data = await _readJson(discussionsFile);
    final topics = (data['topics'] as List).cast<Map<String, dynamic>>();
    final t = topics.firstWhere((m) => m['id'] == id, orElse: () => {});
    if (t.isEmpty) return null;
    return DiscussionTopic.fromMap(t);
  }

  Future<List<DiscussionReply>> listReplies(String topicId) async {
    final data = await _readJson(discussionsFile);
    final items = (data['replies'] as List).cast<Map<String, dynamic>>();
    return items.where((m) => m['topicId'] == topicId).map(DiscussionReply.fromMap).toList();
  }

  Future<DiscussionTopic> createTopic(String title, String content, String author) async {
    final data = await _readJson(discussionsFile);
    final topics = (data['topics'] as List).cast<Map<String, dynamic>>();
    final id = _uuid.v4();
    final t = DiscussionTopic(
      id: id,
      title: title,
      content: content,
      author: author,
      createdAt: DateTime.now(),
      replyCount: 0,
      likeCount: 0,
    );
    topics.add(t.toJson());
    await _writeJson(discussionsFile, {'topics': topics, 'replies': data['replies'] ?? []});
    return t;
  }

  Future<DiscussionReply> createReply(String topicId, String content, String author) async {
    final data = await _readJson(discussionsFile);
    final topics = (data['topics'] as List).cast<Map<String, dynamic>>();
    final replies = (data['replies'] as List).cast<Map<String, dynamic>>();
    final id = _uuid.v4();
    final r = DiscussionReply(
      id: id,
      topicId: topicId,
      content: content,
      author: author,
      createdAt: DateTime.now(),
      likeCount: 0,
    );
    replies.add(r.toJson());
    // bump replyCount on topic
    final idx = topics.indexWhere((m) => m['id'] == topicId);
    if (idx >= 0) {
      final t = topics[idx];
      t['replyCount'] = (t['replyCount'] ?? 0) + 1;
      topics[idx] = t;
    }
    await _writeJson(discussionsFile, {'topics': topics, 'replies': replies});
    return r;
  }

  Future<DiscussionTopic?> likeTopic(String id, int delta) async {
    final data = await _readJson(discussionsFile);
    final topics = (data['topics'] as List).cast<Map<String, dynamic>>();
    final idx = topics.indexWhere((m) => m['id'] == id);
    if (idx < 0) return null;
    final t = topics[idx];
    final curr = (t['likeCount'] ?? 0) as int;
    t['likeCount'] = (curr + delta).clamp(0, 1 << 31);
    topics[idx] = t;
    await _writeJson(discussionsFile, {'topics': topics, 'replies': data['replies'] ?? []});
    return DiscussionTopic.fromMap(t);
  }

  // Auth
  Future<User> register(String email, String password, String name) async {
    final data = await _readJson(usersFile);
    final users = (data['users'] as List).cast<Map<String, dynamic>>();
    if (users.any((u) => u['email'] == email)) {
      throw Exception('email_exists');
    }
    final user = User(id: _uuid.v4(), email: email, name: name, passwordHash: password);
    users.add({'id': user.id, 'email': user.email, 'name': user.name, 'passwordHash': user.passwordHash});
    await _writeJson(usersFile, {'users': users, 'sessions': data['sessions'] ?? {}});
    return user;
  }

  Future<String?> login(String email, String password) async {
    final data = await _readJson(usersFile);
    final users = (data['users'] as List).cast<Map<String, dynamic>>();
    final u = users.cast<Map<String, dynamic>>().firstWhere(
        (it) => it['email'] == email && it['passwordHash'] == password,
        orElse: () => {});
    if (u.isEmpty) return null;
    final token = _uuid.v4();
    final sessions = (data['sessions'] as Map?)?.cast<String, String>() ?? <String, String>{};
    sessions[token] = u['id'];
    await _writeJson(usersFile, {'users': users, 'sessions': sessions});
    return token;
  }

  Future<User?> getUserByToken(String token) async {
    if (token.isEmpty) return null;
    final data = await _readJson(usersFile);
    final sessions = (data['sessions'] as Map?)?.cast<String, String>() ?? <String, String>{};
    final userId = sessions[token];
    if (userId == null) return null;
    final users = (data['users'] as List).cast<Map<String, dynamic>>();
    final m = users.firstWhere((u) => u['id'] == userId, orElse: () => {});
    if (m.isEmpty) return null;
    return User.fromMap(m);
  }

  // Books
  Future<List<Book>> listBooks({String query = ''}) async {
    final data = await _readJson(booksFile);
    final books = (data['books'] as List).cast<Map<String, dynamic>>().map(Book.fromMap).toList();
    if (query.isEmpty) return books;
    return books.where((b) => b.title.toLowerCase().contains(query) || b.author.toLowerCase().contains(query)).toList();
  }

  Future<Book?> getBook(String id) async {
    final data = await _readJson(booksFile);
    final books = (data['books'] as List).cast<Map<String, dynamic>>();
    final m = books.firstWhere((b) => b['id'] == id, orElse: () => {});
    if (m.isEmpty) return null;
    return Book.fromMap(m);
  }

  // Notes
  Future<List<Note>> listNotes({String? bookId}) async {
    final data = await _readJson(notesFile);
    final notes = (data['notes'] as List).cast<Map<String, dynamic>>().map(Note.fromMap).toList();
    if (bookId == null || bookId.isEmpty) return notes;
    return notes.where((n) => n.bookId == bookId).toList();
  }

  Future<Note> createNote(String bookId, String content) async {
    final data = await _readJson(notesFile);
    final notes = (data['notes'] as List).cast<Map<String, dynamic>>();
    final note = Note(id: _uuid.v4(), bookId: bookId, content: content, createdAt: DateTime.now());
    notes.add(note.toJson());
    await _writeJson(notesFile, {'notes': notes});
    return note;
  }

  Future<Note?> updateNote(String id, String content) async {
    final data = await _readJson(notesFile);
    final notes = (data['notes'] as List).cast<Map<String, dynamic>>();
    final idx = notes.indexWhere((n) => n['id'] == id);
    if (idx == -1) return null;
    final m = notes[idx];
    m['content'] = content;
    await _writeJson(notesFile, {'notes': notes});
    return Note.fromMap(m);
  }

  Future<bool> deleteNote(String id) async {
    final data = await _readJson(notesFile);
    final notes = (data['notes'] as List).cast<Map<String, dynamic>>();
    final idx = notes.indexWhere((n) => n['id'] == id);
    if (idx == -1) return false;
    notes.removeAt(idx);
    await _writeJson(notesFile, {'notes': notes});
    return true;
  }
}