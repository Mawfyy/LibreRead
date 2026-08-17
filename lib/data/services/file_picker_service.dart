import 'dart:io';
import 'package:file_picker/file_picker.dart' hide FileType;
import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/utils/file_utils.dart';
import '../models/recent_file.dart';
import 'storage_service.dart';
import 'file_bytes_store.dart';

class FilePickerService {
  static Future<RecentFile?> pickAndOpenFile() async {
    final result = await FilePicker.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc', 'epub'],
    );

    if (result.isEmpty) return null;

    final platformFile = result.first;
    final fileType = _getFileType(platformFile.name);
    final fileSize = await platformFile.length();

    String fileRef;

    if (kIsWeb) {
      final bytes = await platformFile.readAsBytes();
      final id = '${DateTime.now().millisecondsSinceEpoch}_${platformFile.name}';
      FileBytesStore.store(id, bytes);
      fileRef = 'web:$id';
    } else {
      if (platformFile.path == null) return null;
      final sourceFile = File(platformFile.path!);
      final copiedPath = await _copyToAppStorage(sourceFile, platformFile.name);
      fileRef = copiedPath;
    }

    final recentFile = RecentFile(
      name: platformFile.name,
      path: fileRef,
      type: fileType,
      lastOpened: DateTime.now(),
      fileSize: fileSize,
    );

    await StorageService.addOrUpdateFile(recentFile);
    return recentFile;
  }

  static Future<String> _copyToAppStorage(File sourceFile, String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final destPath = p.join(appDir.path, 'documents', fileName);
    final destDir = Directory(p.dirname(destPath));
    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }
    await sourceFile.copy(destPath);
    return destPath;
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
