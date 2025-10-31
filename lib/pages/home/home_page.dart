import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../reader/book_reader_page.dart';
import '../search/search_result_page.dart';
import '../profile/profile_page.dart';
import '../discussion/discussion_page.dart';
import '../analysis/latest_analysis_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<String> _carouselItems = [
    '傲慢与偏见 - 简·奥斯汀',
    '双城记 - 查尔斯·狄更斯',
    '呼啸山庄 - 艾米莉·勃朗特',
    '了不起的盖茨比 - 菲茨杰拉德',
    '动物庄园 - 乔治·奥威尔',
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': '小说', 'icon': Icons.book},
    {'name': '诗歌', 'icon': Icons.music_note},
    {'name': '戏剧', 'icon': Icons.theater_comedy},
    {'name': '散文', 'icon': Icons.article},
    {'name': '传记', 'icon': Icons.person},
    {'name': '历史', 'icon': Icons.history},
  ];

  final List<Map<String, dynamic>> _latestAnalyses = [
    {
      'title': '《傲慢与偏见》人物关系解析',
      'author': '王教授',
      'date': '2023-10-25',
      'preview': '本文将深入分析《傲慢与偏见》中的人物关系，特别是伊丽莎白与达西的性格冲突与和解...'
    },
    {
      'title': '《双城记》历史背景探讨',
      'author': '李老师',
      'date': '2023-10-23',
      'preview': '法国大革命如何影响了狄更斯的创作？本文将从历史角度解读《双城记》的深层含义...'
    },
    {
      'title': '《呼啸山庄》叙事结构分析',
      'author': '张教授',
      'date': '2023-10-20',
      'preview': '多层嵌套的叙事框架如何增强了小说的神秘感和复杂性？本文将详细分析...'
    },
  ];

  final List<Map<String, dynamic>> _hotDiscussions = [
    {
      'title': '达西先生是否真的傲慢？',
      'author': '文学爱好者',
      'replies': 42,
      'lastActive': '2小时前'
    },
    {
      'title': '《动物庄园》的现代意义',
      'author': '思考者',
      'replies': 38,
      'lastActive': '5小时前'
    },
    {
      'title': '盖茨比的美国梦解读',
      'author': '梦想家',
      'replies': 27,
      'lastActive': '昨天'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('英语名著阅读解析'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchResultPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // 显示通知
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 轮播图
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CarouselSlider(
                  items: _carouselItems.map((title) {
                    return Builder(
                      builder: (context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 160,
                    viewportFraction: 0.9,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 指示器
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_carouselItems.length, (idx) {
                  final isActive = _currentIndex == idx;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[400],
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),
              // 最新解析标题与查看更多
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '最新解析',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LatestAnalysisPage(),
                        ),
                      );
                    },
                    child: const Text('查看更多'),
                  ),
                ],
              ),

              // 最新解析卡片（展示一条）
              if (_latestAnalyses.isNotEmpty)
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LatestAnalysisPage(),
                        ),
                      );
                    },
                    child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '《${_latestAnalyses.first['title'].toString().replaceAll('《', '').replaceAll('》', '')}》',
                          // 去掉标题里的《》仅用于展示，如需更严格可拆分
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _latestAnalyses.first['title'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('作者: ${_latestAnalyses.first['author']}'),
                            const SizedBox(width: 12),
                            Text('发布于: ${_latestAnalyses.first['date']}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _latestAnalyses.first['preview'],
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),

              const SizedBox(height: 16),
              // 热门讨论标题与查看更多
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '热门讨论',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DiscussionPage(),
                        ),
                      );
                    },
                    child: const Text('查看更多'),
                  ),
                ],
              ),

              // 热门讨论卡片（展示一条）
              if (_hotDiscussions.isNotEmpty)
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hotDiscussions.first['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('作者: ${_hotDiscussions.first['author']}'),
                            const SizedBox(width: 12),
                            Text('回复数: ${_hotDiscussions.first['replies']}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '最后活跃: ${_hotDiscussions.first['lastActive']}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          }
        },
      ),
    );
  }
}