import 'package:flutter/material.dart';
import '../../data/models/recent_file.dart';
import 'epub_viewer_screen.dart';
import 'txt_viewer_screen.dart';
import 'pdf_viewer_screen.dart';

class ViewerScreen extends StatelessWidget {
  final RecentFile file;

  const ViewerScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    switch (file.type) {
      case FileType.epub:
        return EpubViewerScreen(file: file);
      case FileType.txt:
        return TxtViewerScreen(file: file);
      case FileType.pdf:
        return PdfViewerScreen(file: file);
    }
  }
}
