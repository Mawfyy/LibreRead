import 'package:shared_preferences/shared_preferences.dart';

enum ReadingLayout { vertical, horizontal }

class ReadingLayoutService {
  ReadingLayoutService._();

  static ReadingLayout _layout = ReadingLayout.vertical;

  static ReadingLayout get layout => _layout;
  static bool get isHorizontal => _layout == ReadingLayout.horizontal;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _layout = ReadingLayout.values[prefs.getInt('reading_layout') ?? 0];
  }

  static Future<void> setLayout(ReadingLayout layout) async {
    _layout = layout;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reading_layout', layout.index);
  }
}