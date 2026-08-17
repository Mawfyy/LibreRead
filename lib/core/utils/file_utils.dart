import 'package:path/path.dart' as p;

class FileUtils {
  FileUtils._();

  static bool isWebRef(String path) => path.startsWith('web:');

  static String getWebId(String path) => path.substring(4);

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
