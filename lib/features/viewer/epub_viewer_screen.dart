import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import '../../data/models/recent_file.dart';
import '../../data/services/file_bytes_store.dart';
import '../../core/utils/file_utils.dart';

class EpubViewerScreen extends StatelessWidget {
  final RecentFile file;

  const EpubViewerScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final epubController = EpubController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          file.name,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      body: _buildBody(epubController),
    );
  }

  Widget _buildBody(EpubController controller) {
    if (FileUtils.isWebRef(file.path)) {
      final id = FileUtils.getWebId(file.path);
      final bytes = FileBytesStore.retrieve(id);
      if (bytes == null) {
        return const Center(child: Text('Error: archivo no encontrado'));
      }
      return EpubViewer(
        epubController: controller,
        epubSource: EpubSource.fromData(bytes),
      );
    }

    return FutureBuilder<Uint8List>(
      future: File(file.path).readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return EpubViewer(
          epubController: controller,
          epubSource: EpubSource.fromData(snapshot.data!),
        );
      },
    );
  }
}
