import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Analysis {
  final int id;
  final int bookId;
  final String bookTitle;
  final String title;
  final String author;
  final String content;
  final DateTime publishDate;
  bool isFavorite;

  Analysis({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.title,
    required this.author,
    required this.content,
    required this.publishDate,
    this.isFavorite = false,
  });
}

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  int _selectedCategoryIndex = 0;
  int _selectedAnalysisIndex = 0;
  bool _isTeacher = false; // 用于判断是否显示编辑按钮

  // 模拟分类数据
  final List<String> _categories = ['主题分析', '人物解读', '写作技巧', '历史背景', '文学价值'];

  // 模拟解析数据
  final Map<String, List<Analysis>> _analysisData = {
    '主题分析': [
      Analysis(
        id: 1,
        bookId: 1,
        bookTitle: '傲慢与偏见',
        title: '《傲慢与偏见》中的婚姻观探析',
        author: '王教授',
        content: '''《傲慢与偏见》是简·奥斯汀的代表作，小说通过对不同婚姻的描写，展现了19世纪英国社会的婚姻观念。

本文将从以下几个方面分析小说中的婚姻观：

## 1. 功利性婚姻
小说开篇即点明："有钱的单身汉总想娶位太太，这已经成了一条举世公认的真理。" 这句话揭示了当时社会婚姻的功利性本质。夏洛特与柯林斯的婚姻就是典型的功利性婚姻，夏洛特明确表示她看重的是柯林斯的社会地位和财产，而非爱情。

## 2. 理想婚姻
伊丽莎白与达西的婚姻代表了作者心目中的理想婚姻。他们的结合建立在相互了解、尊重和真挚的爱情基础上，经历了从误解到理解的过程。伊丽莎白拒绝了柯林斯和达西的第一次求婚，表明她不会为了物质利益而委屈自己的婚姻。

## 3. 冲动的婚姻
莉迪亚与威克姆的婚姻代表了盲目冲动的婚姻。莉迪亚被威克姆的外表所吸引，不顾家人反对私奔，最终陷入不幸的婚姻。

## 结论
奥斯汀通过不同类型的婚姻展现了她的婚姻观：真正的婚姻应建立在相互尊重、理解和爱情的基础上，而非仅仅是财产和地位的结合。这一思想在当时的社会环境下显得尤为先进和大胆。''',
        publishDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Analysis(
        id: 2,
        bookId: 1,
        bookTitle: '傲慢与偏见',
        title: '阶级与偏见：《傲慢与偏见》的社会批判',
        author: '李教授',
        content: '''《傲慢与偏见》不仅是一部爱情小说，更是一部对19世纪英国社会阶级制度的深刻批判。本文将探讨小说中的阶级观念与社会偏见。

## 1. 阶级分化与社会流动
小说中的人物按照财富和出身被明确划分为不同的社会阶层。达西家族代表了传统贵族，宾利代表了新兴商人阶级，班内特家族则属于乡绅阶级。奥斯汀通过描绘这些不同阶层的互动，展现了当时英国社会的阶级分化与有限的社会流动性。

## 2. 阶级偏见
达西最初对伊丽莎白的态度充满了阶级偏见，认为与她家族的联姻是"有失身份"的。同样，伊丽莎白对达西的误解也部分源于阶级差异带来的偏见。小说通过这些偏见的逐渐消除，批判了盲目的阶级观念。

## 3. 内在价值与外在地位
奥斯汀通过伊丽莎白这一角色，强调了一个人的内在品质比社会地位更为重要。伊丽莎白凭借其智慧、独立和道德感赢得了达西的尊重和爱情，这表明真正的价值在于个人品质而非社会地位。

## 结论
《傲慢与偏见》通过对阶级制度和社会偏见的批判，表达了奥斯汀对人的内在价值的推崇，以及对社会平等的向往。这种思想在当时的社会背景下具有进步意义，也使得这部作品超越了时代，成为经典。''',
        publishDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ],
    '人物解读': [
      Analysis(
        id: 3,
        bookId: 1,
        bookTitle: '傲慢与偏见',
        title: '伊丽莎白·班内特：理性与感性的平衡',
        author: '张教授',
        content:
            '''伊丽莎白·班内特是《傲慢与偏见》的女主角，也是简·奥斯汀最成功的人物形象之一。本文将深入分析这一角色的性格特点及其在小说中的意义。

## 1. 独立思考的女性
在19世纪英国社会，女性通常被期望顺从、温柔且缺乏主见。而伊丽莎白却展现出了非凡的独立思考能力。她敢于拒绝柯林斯的求婚，尽管这意味着失去继承家族财产的机会；她也敢于拒绝达西的第一次求婚，尽管这意味着放弃优越的物质条件。

## 2. 理性与偏见的矛盾
伊丽莎白自认为是一个理性的观察者，然而她对达西的判断却深受偏见影响。她轻信威克姆的谎言，对达西产生误解，这表明即使是最理性的人也难免受到主观情感的影响。伊丽莎白最终认识到自己的偏见，这一过程体现了她的成长。

## 3. 道德标准与社会规范
伊丽莎白坚持自己的道德标准，不随波逐流。她不像夏洛特那样为了安全感而妥协，也不像莉迪亚那样为了一时冲动而不顾后果。她的婚姻选择基于相互尊重和真挚的感情，而非社会地位或物质条件。

## 4. 幽默感与智慧
伊丽莎白的幽默感是她性格的重要特点。她善于用机智的言辞应对各种社交场合，这不仅展现了她的聪明才智，也是她面对困境时的一种防御机制。

## 结论
伊丽莎白·班内特作为一个复杂而真实的人物形象，体现了奥斯汀对理想女性的构想：既有独立的思想，又不失温情；既能理性判断，又有真挚的情感；既尊重社会规范，又不盲从世俗。这一形象超越了时代，成为文学史上的经典人物。''',
        publishDate: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ],
    '写作技巧': [
      Analysis(
        id: 4,
        bookId: 1,
        bookTitle: '傲慢与偏见',
        title: '《傲慢与偏见》的叙事艺术',
        author: '刘教授',
        content: '''《傲慢与偏见》作为简·奥斯汀的代表作，其叙事艺术达到了极高的水平。本文将分析奥斯汀在这部小说中运用的叙事技巧及其效果。

## 1. 自由间接引语
奥斯汀是自由间接引语的早期使用者之一。这种叙事技巧模糊了叙述者和人物之间的界限，使读者能够同时感受到叙述者的客观描述和人物的主观感受。例如，在描述伊丽莎白对达西的印象转变时，奥斯汀巧妙地融合了叙述者的视角和伊丽莎白的内心活动。

## 2. 讽刺与幽默
讽刺是奥斯汀叙事的重要特色。小说开篇那句著名的话："有钱的单身汉总想娶位太太，这已经成了一条举世公认的真理。"就充满了讽刺意味。奥斯汀通过幽默的对话和细致的人物描写，巧妙地讽刺了当时社会的婚姻观念和阶级偏见。

## 3. 限制视角
尽管小说采用了第三人称叙述，但视角主要限制在伊丽莎白身上。读者大多通过伊丽莎白的眼睛看世界，这使得读者能够与主人公产生共鸣，同时也使得情节发展充满悬念——读者只能知道伊丽莎白所知道的信息。

## 4. 对话的艺术
奥斯汀善于通过对话展现人物性格和推动情节发展。小说中的对话生动自然，富有个性，每个人物都有自己独特的说话方式。例如，班内特太太的唠叨、柯林斯先生的做作、达西的简洁有力，都通过对话鲜明地表现出来。

## 结论
奥斯汀的叙事艺术将日常生活中的细节提升为艺术，通过精心设计的叙事结构、限制视角、自由间接引语以及生动的对话，创造了一个真实而丰富的小说世界。这些叙事技巧不仅使《傲慢与偏见》成为经典，也对后世的小说创作产生了深远影响。''',
        publishDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ],
    '历史背景': [
      Analysis(
        id: 5,
        bookId: 1,
        bookTitle: '傲慢与偏见',
        title: '摄政时期的英国社会与《傲慢与偏见》',
        author: '周教授',
        content:
            '''《傲慢与偏见》创作于19世纪初的英国，这一时期正值摄政时代（Regency Era）。本文将探讨这一历史背景对小说的影响。

## 1. 社会结构与阶级制度
摄政时期的英国社会结构严格，阶级界限分明。贵族和地主阶级占据社会顶层，中产阶级（如医生、律师、商人）地位逐渐上升，而普通民众则生活困难。小说中班内特家族属于没有爵位的乡绅阶级，达西则代表了有爵位的大地主阶级。

## 2. 女性地位与婚姻制度
当时的女性地位低下，缺乏经济独立性，婚姻成为她们获得经济保障的主要途径。英国的继承法规定财产通常由男性继承，这就是为什么班内特家族没有儿子而面临财产被远房亲戚继承的困境。小说中的婚姻观念直接反映了这一社会现实。

## 3. 社交礼仪与乡村生活
摄政时期的社交活动有着严格的礼仪规范。小说中描述的舞会、拜访、书信往来等都遵循当时的社交规则。同时，奥斯汀也真实地描绘了英国乡村生活的日常细节，如散步、读书、音乐会等休闲活动。

## 4. 拿破仑战争的影响
虽然小说中很少直接提及，但拿破仑战争是当时英国社会的重要背景。军官在社会上享有较高声望，这解释了为什么威克姆这样的军官能够吸引年轻女性的注意。梅里顿驻扎的民兵团也是战争背景下的产物。

## 结论
《傲慢与偏见》虽然是一部关注个人情感和道德的小说，但它深深植根于特定的历史土壤。通过了解摄政时期的英国社会背景，我们能够更深入地理解小说中的人物行为和价值观念，也能更好地欣赏奥斯汀对当时社会的细致观察和巧妙批判。''',
        publishDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ],
    '文学价值': [
      Analysis(
        id: 6,
        bookId: 1,
        bookTitle: '傲慢与偏见',
        title: '《傲慢与偏见》的文学地位与影响',
        author: '陈教授',
        content: '''《傲慢与偏见》自1813年出版以来，一直被视为英国文学的经典之作。本文将探讨这部小说的文学价值及其对后世的影响。

## 1. 现实主义的先驱
奥斯汀被认为是英国现实主义小说的先驱之一。她摒弃了当时流行的哥特式小说的夸张情节，转而关注日常生活中的真实细节和人物心理。《傲慢与偏见》中对乡村社会、家庭生活和人际关系的细致描写，为后来的现实主义文学奠定了基础。

## 2. 女性文学的里程碑
作为一位女性作家，奥斯汀在男性主导的文学界取得了巨大成就。她创造的伊丽莎白·班内特形象，代表了一种新型的女性意识——既不盲从传统，也不激进反叛，而是在现有社会框架内寻求自我价值的实现。这一形象对后来的女性文学产生了深远影响。

## 3. 心理小说的开拓
奥斯汀善于描写人物的心理活动，尤其是女性内心世界的微妙变化。《傲慢与偏见》中伊丽莎白从误解到理解达西的心理过程，被细腻而真实地呈现出来。这种对人物心理的关注，使奥斯汀成为心理小说的重要开拓者。

## 4. 永恒的艺术魅力
《傲慢与偏见》之所以能够跨越两个世纪依然受到读者喜爱，在于它所探讨的主题具有永恒价值：爱情与婚姻、偏见与理解、个人成长与社会规范等。这些主题在任何时代都具有现实意义。

## 5. 对后世的影响
《傲慢与偏见》对后世文学、电影、电视剧等艺术形式产生了广泛影响。它不仅被多次改编为电影和电视剧，还启发了众多现代作品，如《傲慢与偏见与僵尸》等跨类型创作。此外，小说中的人物和情节也成为流行文化中的重要元素。

## 结论
《傲慢与偏见》作为英国文学的经典之作，其艺术成就和思想价值已经得到了时间的检验。它不仅是一部优秀的爱情小说，更是一部对人性和社会有着深刻洞察的文学杰作。奥斯汀通过这部作品展现的艺术才华和人文关怀，使其成为世界文学宝库中的珍品。''',
        publishDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    // 检查用户身份，确定是否为教师
    _checkUserRole();
  }

  // 检查用户角色
  void _checkUserRole() async {
    // 实际应用中应该从Provider或本地存储获取用户角色
    // 这里模拟用户是教师
    setState(() {
      _isTeacher = true;
    });
  }

  // 切换收藏状态
  void _toggleFavorite() {
    final currentCategory = _categories[_selectedCategoryIndex];
    if (_analysisData[currentCategory]!.isNotEmpty) {
      setState(() {
        final analysis =
            _analysisData[currentCategory]![_selectedAnalysisIndex];
        analysis.isFavorite = !analysis.isFavorite;

        Fluttertoast.showToast(
          msg: analysis.isFavorite ? '已添加到收藏' : '已取消收藏',
          toastLength: Toast.LENGTH_SHORT,
        );
      });
    }
  }

  // 编辑解析
  void _editAnalysis() {
    final currentCategory = _categories[_selectedCategoryIndex];
    if (_analysisData[currentCategory]!.isNotEmpty) {
      final analysis = _analysisData[currentCategory]![_selectedAnalysisIndex];

      // 实际应用中应该跳转到编辑页面
      Fluttertoast.showToast(
        msg: '编辑功能开发中...',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  // 添加新解析
  void _addNewAnalysis() {
    // 实际应用中应该跳转到创建页面
    Fluttertoast.showToast(
      msg: '创建新解析功能开发中...',
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('名著解析'),
        actions: [
          if (_isTeacher)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addNewAnalysis,
              tooltip: '创建新解析',
            ),
        ],
      ),
      body: Row(
        children: [
          // 左侧导航栏
          Container(
            width: isTablet ? 200 : 100,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                // 分类列表
                Expanded(
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          _categories[index],
                          style: TextStyle(fontSize: isTablet ? 16 : 14),
                        ),
                        selected: _selectedCategoryIndex == index,
                        selectedTileColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                            _selectedAnalysisIndex = 0; // 重置选中的解析索引
                          });
                        },
                      );
                    },
                  ),
                ),

                // 分隔线
                Divider(height: 1, color: Colors.grey[300]),

                // 当前分类下的解析列表
                Expanded(flex: 2, child: _buildAnalysisList()),
              ],
            ),
          ),

          // 右侧解析详情
          Expanded(child: _buildAnalysisDetail()),
        ],
      ),
    );
  }

  // 构建解析列表
  Widget _buildAnalysisList() {
    final currentCategory = _categories[_selectedCategoryIndex];
    final analysisList = _analysisData[currentCategory] ?? [];

    if (analysisList.isEmpty) {
      return const Center(child: Text('暂无解析内容'));
    }

    return ListView.builder(
      itemCount: analysisList.length,
      itemBuilder: (context, index) {
        final analysis = analysisList[index];
        return ListTile(
          title: Text(
            analysis.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: _selectedAnalysisIndex == index
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          subtitle: Text(analysis.author, style: const TextStyle(fontSize: 12)),
          selected: _selectedAnalysisIndex == index,
          selectedTileColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          onTap: () {
            setState(() {
              _selectedAnalysisIndex = index;
            });
          },
        );
      },
    );
  }

  // 构建解析详情
  Widget _buildAnalysisDetail() {
    final currentCategory = _categories[_selectedCategoryIndex];
    final analysisList = _analysisData[currentCategory] ?? [];

    if (analysisList.isEmpty) {
      return const Center(child: Text('请选择一篇解析'));
    }

    final analysis = analysisList[_selectedAnalysisIndex];

    return Column(
      children: [
        // 顶部信息栏
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${analysis.author} · ${analysis.publishDate.year}/${analysis.publishDate.month}/${analysis.publishDate.day}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // 收藏按钮
              IconButton(
                icon: Icon(
                  analysis.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: analysis.isFavorite ? Colors.red : null,
                ),
                onPressed: _toggleFavorite,
                tooltip: analysis.isFavorite ? '取消收藏' : '添加收藏',
              ),
              // 教师可见的编辑按钮
              if (_isTeacher)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editAnalysis,
                  tooltip: '编辑解析',
                ),
            ],
          ),
        ),

        // 解析内容
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              analysis.content,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
