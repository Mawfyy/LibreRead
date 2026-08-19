import 'dart:io';
import 'package:epub_pro/epub_pro.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class CoverCacheService {
  CoverCacheService._();

  static Future<String> _getCacheDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(p.join(dir.path, 'thumbnails'));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  static String _hashPath(String filePath) {
    return filePath.hashCode.toRadixString(16);
  }

  static Future<File?> getCover(String filePath) async {
    final cacheDir = await _getCacheDir();
    final file = File(p.join(cacheDir, '${_hashPath(filePath)}.png'));
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  static Future<String?> extractAndCacheCover(String filePath) async {
    final existing = await getCover(filePath);
    if (existing != null) return existing.path;

    try {
      final sourceFile = File(filePath);
      if (!await sourceFile.exists()) return null;

      final fileSize = await sourceFile.length();
      if (fileSize > 10 * 1024 * 1024) return null;

      final bytes = await sourceFile.readAsBytes();
      final bookRef = await EpubReader.openBook(bytes);
      final coverImage = await bookRef.readCover();

      if (coverImage == null) return null;

      final pngBytes = img.encodePng(coverImage);
      final cacheDir = await _getCacheDir();
      final destFile = File(p.join(cacheDir, '${_hashPath(filePath)}.png'));
      await destFile.writeAsBytes(pngBytes);
      return destFile.path;
    } catch (_) {
      return null;
    }
  }
}
