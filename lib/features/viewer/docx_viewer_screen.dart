import 'package:flutter/material.dart';
import 'package:docx_file_viewer/docx_file_viewer.dart';
import '../../data/models/recent_file.dart';
import '../../data/services/file_bytes_store.dart';
import '../../core/utils/file_utils.dart';

class DocxViewerScreen extends StatelessWidget {
  final RecentFile file;

  const DocxViewerScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          file.name,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      body: _buildViewer(),
    );
  }

  Widget _buildViewer() {
    if (FileUtils.isWebRef(file.path)) {
      final id = FileUtils.getWebId(file.path);
      final bytes = FileBytesStore.retrieve(id);
      if (bytes == null) {
        return const Center(child: Text('Error: archivo no encontrado'));
      }
      return DocxView(bytes: bytes);
    }
    return DocxView(path: file.path);
  }
}
