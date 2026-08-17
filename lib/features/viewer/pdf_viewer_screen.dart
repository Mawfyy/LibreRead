import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../data/models/recent_file.dart';
import '../../data/services/file_bytes_store.dart';
import '../../core/utils/file_utils.dart';

class PdfViewerScreen extends StatelessWidget {
  final RecentFile file;

  const PdfViewerScreen({super.key, required this.file});

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
      return PdfViewer.data(bytes, sourceName: file.name);
    }
    return PdfViewer.file(file.path);
  }
}
