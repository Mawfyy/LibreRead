import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';

class LectorDocumentosApp extends StatefulWidget {
  const LectorDocumentosApp({super.key});

  static void setTheme(BuildContext context, ThemeMode mode) {
    final state = context.findAncestorStateOfType<_LectorDocumentosAppState>();
    state?.setTheme(mode);
  }

  static ThemeMode currentTheme(BuildContext context) {
    final state = context.findAncestorStateOfType<_LectorDocumentosAppState>();
    return state?.themeMode ?? ThemeMode.system;
  }

  @override
  State<LectorDocumentosApp> createState() => _LectorDocumentosAppState();
}

class _LectorDocumentosAppState extends State<LectorDocumentosApp> {
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
      title: 'Lector de Documentos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: const HomeScreen(),
    );
  }
}
