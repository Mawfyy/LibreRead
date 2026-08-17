import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import '../../data/models/recent_file.dart';

class EpubViewerScreen extends StatefulWidget {
  final RecentFile file;

  const EpubViewerScreen({super.key, required this.file});

  @override
  State<EpubViewerScreen> createState() => _EpubViewerScreenState();
}

class _EpubViewerScreenState extends State<EpubViewerScreen> {
  EpubController? _controller;

  @override
  void initState() {
    super.initState();
    _loadEpub();
  }

  Future<void> _loadEpub() async {
    try {
      final epubSource = await EpubSource.fromFile(
        File(widget.file.path),
      );
      _controller = EpubController(
        epubSource: epubSource,
      );
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar EPUB: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.file.name,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : EpubViewer(
              controller: _controller!,
            ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
