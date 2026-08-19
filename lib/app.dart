import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';

class LibreReadApp extends StatefulWidget {
  const LibreReadApp({super.key});

  static void setTheme(BuildContext context, ThemeMode mode) {
    final state = context.findAncestorStateOfType<_LibreReadAppState>();
    state?.setTheme(mode);
  }

  static ThemeMode currentTheme(BuildContext context) {
    final state = context.findAncestorStateOfType<_LibreReadAppState>();
    return state?._themeMode ?? ThemeMode.system;
  }

  @override
  State<LibreReadApp> createState() => _LibreReadAppState();
}

class _LibreReadAppState extends State<LibreReadApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    setState(() {
      _themeMode = ThemeMode.values[themeIndex];
    });
  }

  void setTheme(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LibreRead',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: const HomeScreen(),
    );
  }
}
