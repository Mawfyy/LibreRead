import 'package:shared_preferences/shared_preferences.dart';

class ReadingPositionService {
  ReadingPositionService._();

  static Future<void> savePosition(String filePath, String cfi, double progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reading_pos_$filePath', cfi);
    await prefs.setDouble('reading_progress_$filePath', progress);
  }

  static Future<String?> getCfi(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('reading_pos_$filePath');
  }

  static Future<double?> getProgress(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('reading_progress_$filePath');
  }
}
