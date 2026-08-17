import 'package:hive_ce/hive.dart';
import '../models/recent_file.dart';

class StorageService {
  static late Box<RecentFile> _recentFilesBox;
  static late Box _settingsBox;

  static const String _recentFilesBoxName = 'recent_files';
  static const String _settingsBoxName = 'settings';
  static const int _maxRecentFiles = 50;

  static Future<void> init() async {
    Hive.registerAdapter(RecentFileAdapter());
    Hive.registerAdapter(FileTypeAdapter());
    _recentFilesBox = await Hive.openBox<RecentFile>(_recentFilesBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  static List<RecentFile> getRecentFiles() {
    final files = _recentFilesBox.values.toList();
    files.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
    return files;
  }

  static Future<void> addOrUpdateFile(RecentFile file) async {
    final existingKey = _recentFilesBox.values.toList().indexWhere(
      (f) => f.path == file.path,
    );

    if (existingKey >= 0) {
      await _recentFilesBox.putAt(existingKey, file);
    } else {
      if (_recentFilesBox.length >= _maxRecentFiles) {
        final files = getRecentFiles();
        final oldest = files.last;
        final oldestKey = _recentFilesBox.values.toList().indexWhere(
          (f) => f.path == oldest.path,
        );
        if (oldestKey >= 0) {
          await _recentFilesBox.deleteAt(oldestKey);
        }
      }
      await _recentFilesBox.add(file);
    }
  }

  static Future<void> removeFile(String path) async {
    final key = _recentFilesBox.values.toList().indexWhere(
      (f) => f.path == path,
    );
    if (key >= 0) {
      await _recentFilesBox.deleteAt(key);
    }
  }

  static Future<void> clearAll() async {
    await _recentFilesBox.clear();
  }

  static double getFontSize() {
    return _settingsBox.get('font_size', defaultValue: 1.0);
  }

  static Future<void> setFontSize(double size) async {
    await _settingsBox.put('font_size', size);
  }
}
