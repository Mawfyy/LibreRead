import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../data/models/recent_file.dart';

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
      body: PdfViewer.file(
        File(file.path),
      ),
    );
  }
}
