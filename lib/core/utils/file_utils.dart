import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileUtils {
  FileUtils._();

  static Future<String> copyFileToAppStorage(File sourceFile, String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final destPath = p.join(appDir.path, 'documents', fileName);

    final destDir = Directory(p.dirname(destPath));
    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }

    await sourceFile.copy(destPath);
    return destPath;
  }

  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static String getFileExtension(String fileName) {
    return p.extension(fileName).toLowerCase();
  }

  static String getFileType(String fileName) {
    final ext = getFileExtension(fileName);
    switch (ext) {
      case '.pdf':
        return 'PDF';
      case '.docx':
      case '.doc':
        return 'Word';
      case '.epub':
        return 'EPUB';
      default:
        return 'Desconocido';
    }
  }

  static bool isSupportedFile(String fileName) {
    final ext = getFileExtension(fileName);
    return ['.pdf', '.docx', '.doc', '.epub'].contains(ext);
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
