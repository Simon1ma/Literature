import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 页面：使用独立文件中的完整实现
import 'pages/auth/login_register_page.dart';
import 'pages/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Hive数据库
  await Hive.initFlutter();
  
  // 初始化SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ReaderProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

// 用户状态管理
class UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userType = 'student'; // 'student' 或 'teacher'
  String _userId = '';
  String _username = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userType => _userType;
  String get userId => _userId;
  String get username => _username;

  void login(String userId, String username, String userType) {
    _isLoggedIn = true;
    _userId = userId;
    _username = username;
    _userType = userType;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userId = '';
    _username = '';
    notifyListeners();
  }
}

// 主题状态管理
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

// 阅读状态管理
class ReaderProvider extends ChangeNotifier {
  int _currentBookId = 0;
  int _currentChapter = 0;
  double _scrollPosition = 0.0;
  double _fontSize = 16.0;

  int get currentBookId => _currentBookId;
  int get currentChapter => _currentChapter;
  double get scrollPosition => _scrollPosition;
  double get fontSize => _fontSize;

  void setBook(int bookId) {
    _currentBookId = bookId;
    _currentChapter = 0;
    _scrollPosition = 0.0;
    notifyListeners();
  }

  void setChapter(int chapter) {
    _currentChapter = chapter;
    _scrollPosition = 0.0;
    notifyListeners();
  }

  void setScrollPosition(double position) {
    _scrollPosition = position;
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: '英语名著阅读解析',
      theme: ThemeData(
        primaryColor: const Color(0xFF4A90E2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2),
          secondary: const Color(0xFFF5A623),
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            height: 1.5,
            letterSpacing: 0.5,
          ),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF4A90E2),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF4A90E2),
          secondary: const Color(0xFFF5A623),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            height: 1.5,
            letterSpacing: 0.5,
          ),
        ),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: isLoggedIn ? const HomePage() : const LoginRegisterPage(),
    );
  }
}

// 已移除 main.dart 中的临时 Home/Login 页面，改为使用 pages 目录下的完整实现
