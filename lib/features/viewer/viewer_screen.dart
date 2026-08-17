import 'package:flutter/material.dart';
import '../../data/models/recent_file.dart';
import 'pdf_viewer_screen.dart';
import 'docx_viewer_screen.dart';
import 'epub_viewer_screen.dart';

class ViewerScreen extends StatelessWidget {
  final RecentFile file;

  const ViewerScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    switch (file.type) {
      case FileType.pdf:
        return PdfViewerScreen(file: file);
      case FileType.docx:
        return DocxViewerScreen(file: file);
      case FileType.epub:
        return EpubViewerScreen(file: file);
    }
  }
}
