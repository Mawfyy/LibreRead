import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../data/models/recent_file.dart';
import '../../data/models/reader_settings.dart';
import '../../data/services/reader_settings_service.dart';
import 'widgets/eye_care_filter.dart';
import 'widgets/immersive_reader.dart';

class PdfViewerScreen extends StatefulWidget {
  final RecentFile file;

  const PdfViewerScreen({super.key, required this.file});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ReaderSettingsService.settingsFor(ReaderFormat.pdf);
    final bgColor = settings.backgroundColor;
    return ImmersiveReader(
      title: widget.file.name,
      body: EyeCareFilter(
        settings: settings,
        child: PdfViewer.file(
          widget.file.path,
          params: PdfViewerParams(
            backgroundColor: settings.backgroundColor,
            layoutPages: settings.layout == ReadingLayout.horizontal
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
      ),
      fullscreen: settings.fullscreen,
      onFullscreenChanged: (value) async {
        final current = ReaderSettingsService.settingsFor(ReaderFormat.pdf);
        await ReaderSettingsService.update(
          ReaderFormat.pdf,
          current.copyWith(fullscreen: value),
        );
        if (mounted) setState(() {});
      },
      backgroundColor: bgColor,
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