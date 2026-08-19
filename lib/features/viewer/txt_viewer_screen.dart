import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/recent_file.dart';
import '../../data/models/reader_settings.dart';
import '../../data/services/reader_settings_service.dart';
import 'widgets/eye_care_filter.dart';

class TxtViewerScreen extends StatelessWidget {
  final RecentFile file;

  const TxtViewerScreen({super.key, required this.file});

  Future<String> _loadContent() async {
    return File(file.path).readAsString();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ReaderSettingsService.settingsFor(ReaderFormat.txt);
    final bgColor = settings.backgroundColor;
    final fgColor = settings.textColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(file.name),
      ),
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
                        fontSize: settings.fontSize,
                        height: 1.6,
                        color: fgColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
