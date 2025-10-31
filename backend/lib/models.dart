import 'dart:convert';

class User {
  final String id;
  final String email;
  final String name;
  final String passwordHash; // 简化：明文或简单hash

  User({required this.id, required this.email, required this.name, required this.passwordHash});

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
      };

  static User fromMap(Map<String, dynamic> m) => User(
        id: m['id'],
        email: m['email'],
        name: m['name'] ?? '',
        passwordHash: m['passwordHash'] ?? '',
      );
}

class Book {
  final String id;
  final String title;
  final String author;
  final String description;

  Book({required this.id, required this.title, required this.author, required this.description});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'description': description,
      };

  static Book fromMap(Map<String, dynamic> m) => Book(
        id: m['id'],
        title: m['title'],
        author: m['author'] ?? '',
        description: m['description'] ?? '',
      );
}

class Note {
  final String id;
  final String bookId;
  final String content;
  final DateTime createdAt;

  Note({required this.id, required this.bookId, required this.content, required this.createdAt});

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  static Note fromMap(Map<String, dynamic> m) => Note(
        id: m['id'],
        bookId: m['bookId'],
        content: m['content'] ?? '',
        createdAt: DateTime.parse(m['createdAt']),
      );
}

class DiscussionTopic {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  final int replyCount;
  final int likeCount;

  DiscussionTopic({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.replyCount,
    required this.likeCount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'author': author,
        'createdAt': createdAt.toIso8601String(),
        'replyCount': replyCount,
        'likeCount': likeCount,
      };

  static DiscussionTopic fromMap(Map<String, dynamic> m) => DiscussionTopic(
        id: m['id'],
        title: m['title'] ?? '',
        content: m['content'] ?? '',
        author: m['author'] ?? '',
        createdAt: DateTime.parse(m['createdAt']),
        replyCount: (m['replyCount'] ?? 0) as int,
        likeCount: (m['likeCount'] ?? 0) as int,
      );
}

class DiscussionReply {
  final String id;
  final String topicId;
  final String content;
  final String author;
  final DateTime createdAt;
  final int likeCount;

  DiscussionReply({
    required this.id,
    required this.topicId,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.likeCount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicId': topicId,
        'content': content,
        'author': author,
        'createdAt': createdAt.toIso8601String(),
        'likeCount': likeCount,
      };

  static DiscussionReply fromMap(Map<String, dynamic> m) => DiscussionReply(
        id: m['id'],
        topicId: m['topicId'],
        content: m['content'] ?? '',
        author: m['author'] ?? '',
        createdAt: DateTime.parse(m['createdAt']),
        likeCount: (m['likeCount'] ?? 0) as int,
      );
}