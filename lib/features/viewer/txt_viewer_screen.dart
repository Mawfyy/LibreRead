import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/recent_file.dart';
import '../../data/models/reader_settings.dart';
import '../../data/services/reader_settings_service.dart';
import 'widgets/eye_care_filter.dart';
import 'widgets/immersive_reader.dart';

class TxtViewerScreen extends StatefulWidget {
  final RecentFile file;

  const TxtViewerScreen({super.key, required this.file});

  @override
  State<TxtViewerScreen> createState() => _TxtViewerScreenState();
}

class _TxtViewerScreenState extends State<TxtViewerScreen> {
  Future<String> _loadContent() async {
    return File(widget.file.path).readAsString();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ReaderSettingsService.settingsFor(ReaderFormat.txt);
    final bgColor = settings.backgroundColor;

    return ImmersiveReader(
      title: widget.file.name,
      body: EyeCareFilter(
        settings: settings,
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
            final isHorizontal = settings.layout == ReadingLayout.horizontal;
            return SingleChildScrollView(
              scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: isHorizontal ? Axis.vertical : Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: isHorizontal
                        ? MediaQuery.of(context).size.width - 32
                        : 0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      content,
                      style: TextStyle(
                        fontSize: settings.txt.fontSize,
                        height: settings.txt.lineHeight,
                        color: settings.textColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      fullscreen: settings.fullscreen,
      onFullscreenChanged: (value) async {
        final current = ReaderSettingsService.settingsFor(ReaderFormat.txt);
        await ReaderSettingsService.update(
          ReaderFormat.txt,
          current.copyWith(fullscreen: value),
        );
        if (mounted) setState(() {});
      },
      backgroundColor: bgColor,
    );
  }
}
