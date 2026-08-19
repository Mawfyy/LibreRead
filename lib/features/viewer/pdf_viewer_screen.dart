import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../data/models/recent_file.dart';
import '../../data/services/reading_layout_service.dart';

class PdfViewerScreen extends StatefulWidget {
  final RecentFile file;

  const PdfViewerScreen({super.key, required this.file});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.file.name,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      body: PdfViewer.file(
        widget.file.path,
        params: PdfViewerParams(
          backgroundColor: Colors.white,
          layoutPages: ReadingLayoutService.isHorizontal
              ? _horizontalLayout
              : null,
          errorBannerBuilder: (context, error, stackTrace, documentRef) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load PDF',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PdfPageLayout _horizontalLayout(
    List<PdfPage> pages,
    PdfViewerParams params,
  ) {
    final height = pages.fold(
      0.0,
      (prev, page) => math.max(prev, page.height),
    ) + params.margin * 2;
    final pageLayouts = <Rect>[];
    var x = params.margin;
    for (final page in pages) {
      pageLayouts.add(
        Rect.fromLTWH(
          x,
          (height - page.height) / 2,
          page.width,
          page.height,
        ),
      );
      x += page.width + params.margin;
    }
    return PdfPageLayout(
      pageLayouts: pageLayouts,
      documentSize: Size(x, height),
    );
  }
}