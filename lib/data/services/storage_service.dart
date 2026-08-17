import 'package:shared_preferences/shared_preferences.dart';
import '../models/recent_file.dart';

class StorageService {
  static List<RecentFile> _recentFiles = [];
  static const int _maxRecentFiles = 50;

  static Future<void> init() async {
    _recentFiles = await _loadFromPrefs();
  }

  static List<RecentFile> getRecentFiles() {
    final sorted = List<RecentFile>.from(_recentFiles);
    sorted.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
    return sorted;
  }

  static Future<void> addOrUpdateFile(RecentFile file) async {
    final idx = _recentFiles.indexWhere((f) => f.path == file.path);
    if (idx >= 0) {
      _recentFiles[idx] = file;
    } else {
      if (_recentFiles.length >= _maxRecentFiles) {
        _recentFiles.sort((a, b) => a.lastOpened.compareTo(b.lastOpened));
        _recentFiles.removeAt(0);
      }
      _recentFiles.add(file);
    }
    await _saveToPrefs();
  }

  static Future<void> removeFile(String path) async {
    _recentFiles.removeWhere((f) => f.path == path);
    await _saveToPrefs();
  }

  static Future<void> clearAll() async {
    _recentFiles.clear();
    await _saveToPrefs();
  }

  static Future<List<RecentFile>> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final filesJson = prefs.getStringList('recent_files') ?? [];
    return filesJson.map((json) => RecentFile.fromJson(json)).toList();
  }

  static Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final filesJson = _recentFiles.map((f) => f.toJsonString()).toList();
    await prefs.setStringList('recent_files', filesJson);
  }
}
