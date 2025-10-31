import 'package:flutter/material.dart';
import 'analysis_repository.dart';

class AnalysisDetailPage extends StatelessWidget {
  final AnalysisItem item;
  const AnalysisDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('解析文章'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title.isNotEmpty
                    ? '《${item.bookTitle}》：${item.title}'
                    : '《${item.bookTitle}》解析',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${item.author} · ${item.publishDate.year}-${item.publishDate.month}-${item.publishDate.day}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              Text(
                item.content,
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}