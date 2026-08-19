import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/recent_file.dart';
import '../../data/services/eye_care_service.dart';
import '../../core/utils/file_utils.dart';
import '../../data/services/file_bytes_store.dart';
import 'widgets/eye_care_filter.dart';

class TxtViewerScreen extends StatelessWidget {
  final RecentFile file;

  const TxtViewerScreen({super.key, required this.file});

  Future<String> _loadContent() async {
    if (FileUtils.isWebRef(file.path)) {
      final bytes = FileBytesStore.retrieve(FileUtils.getWebId(file.path));
      if (bytes != null) return String.fromCharCodes(bytes);
      return '';
    }
    return File(file.path).readAsString();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = EyeCareService.backgroundColor;
    final fgColor = EyeCareService.textColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(file.name),
      ),
      body: EyeCareFilter(
        child: FutureBuilder<String>(
          future: _loadContent(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final content = snapshot.data ?? '';
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                content,
                style: TextStyle(
                  fontSize: EyeCareService.fontSize,
                  height: 1.6,
                  color: fgColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
