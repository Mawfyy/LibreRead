import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../core/utils/file_utils.dart';
import '../models/recent_file.dart';
import 'storage_service.dart';

class FilePickerService {
  static Future<RecentFile?> pickAndOpenFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc', 'epub'],
    );

    if (result == null || result.files.isEmpty) return null;

    final platformFile = result.files.first;
    if (platformFile.path == null) return null;

    final sourceFile = File(platformFile.path!);
    final copiedPath = await FileUtils.copyFileToAppStorage(
      sourceFile,
      platformFile.name,
    );

    final fileType = _getFileType(platformFile.name);

    final recentFile = RecentFile(
      name: platformFile.name,
      path: copiedPath,
      type: fileType,
      lastOpened: DateTime.now(),
      fileSize: platformFile.size,
    );

    await StorageService.addOrUpdateFile(recentFile);
    return recentFile;
  }

  static FileType _getFileType(String fileName) {
    final ext = FileUtils.getFileExtension(fileName);
    switch (ext) {
      case '.pdf':
        return FileType.pdf;
      case '.docx':
      case '.doc':
        return FileType.docx;
      case '.epub':
        return FileType.epub;
      default:
        return FileType.pdf;
    }
  }
}
