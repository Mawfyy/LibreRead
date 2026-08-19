import 'package:shared_preferences/shared_preferences.dart';
import '../models/epub_bookmark.dart';

class EpubBookmarkService {
  EpubBookmarkService._();

  static Future<List<EpubBookmark>> getBookmarks(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'epub_bookmarks_$filePath';
    final jsonList = prefs.getStringList(key) ?? [];
    return jsonList.map((json) => EpubBookmark.fromJson(json)).toList();
  }

  static Future<void> addBookmark(String filePath, EpubBookmark bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'epub_bookmarks_$filePath';
    final bookmarks = await getBookmarks(filePath);
    bookmarks.add(bookmark);
    final jsonList = bookmarks.map((b) => b.toJsonString()).toList();
    await prefs.setStringList(key, jsonList);
  }

  static Future<void> removeBookmark(String filePath, String cfi) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'epub_bookmarks_$filePath';
    final bookmarks = await getBookmarks(filePath);
    bookmarks.removeWhere((b) => b.cfi == cfi);
    final jsonList = bookmarks.map((b) => b.toJsonString()).toList();
    await prefs.setStringList(key, jsonList);
  }
}
