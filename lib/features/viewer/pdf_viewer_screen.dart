import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../../core/utils/file_utils.dart';
import '../../data/models/recent_file.dart';
import '../../data/services/file_bytes_store.dart';

class PdfViewerScreen extends StatefulWidget {
  final RecentFile file;

  const PdfViewerScreen({super.key, required this.file});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late final PdfControllerPinch _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(
      document: _openDocument(),
    );
    _controller.loadingState.addListener(() {
      if (_controller.loadingState.value == PdfLoadingState.error && mounted) {
        setState(() {
          _error = 'Failed to load PDF';
        });
      }
    });
  }

  Future<PdfDocument> _openDocument() async {
    if (FileUtils.isWebRef(widget.file.path)) {
      final id = FileUtils.getWebId(widget.file.path);
      final bytes = FileBytesStore.retrieve(id);
      if (bytes == null) throw Exception('File not in memory');
      return PdfDocument.openData(bytes);
    }
    return PdfDocument.openFile(widget.file.path);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      );
    }

    return PdfViewPinch(
      controller: _controller,
    );
  }
}
