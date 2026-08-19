import 'package:flutter/material.dart';

enum ReadingBackground { white, sepia, dark, highContrast }

enum ReadingLayout { vertical, horizontal }

enum ReaderFormat { epub, pdf, txt }

class ReaderSettings {
  final ReadingBackground background;
  final double fontSize;
  final bool blueLightEnabled;
  final double blueLightIntensity;
  final ReadingLayout layout;

  const ReaderSettings({
    this.background = ReadingBackground.white,
    this.fontSize = 16.0,
    this.blueLightEnabled = false,
    this.blueLightIntensity = 0.3,
    this.layout = ReadingLayout.vertical,
  });

  static const ReaderSettings defaults = ReaderSettings();

  ReaderSettings copyWith({
    ReadingBackground? background,
    double? fontSize,
    bool? blueLightEnabled,
    double? blueLightIntensity,
    ReadingLayout? layout,
  }) {
    return ReaderSettings(
      background: background ?? this.background,
      fontSize: fontSize ?? this.fontSize,
      blueLightEnabled: blueLightEnabled ?? this.blueLightEnabled,
      blueLightIntensity: blueLightIntensity ?? this.blueLightIntensity,
      layout: layout ?? this.layout,
    );
  }

  Color get backgroundColor {
    switch (background) {
      case ReadingBackground.white:
        return Colors.white;
      case ReadingBackground.sepia:
        return const Color(0xFFF5E6C8);
      case ReadingBackground.dark:
        return const Color(0xFF1A1A1A);
      case ReadingBackground.highContrast:
        return Colors.black;
    }
  }

  Color get textColor {
    switch (background) {
      case ReadingBackground.white:
        return const Color(0xFF212121);
      case ReadingBackground.sepia:
        return const Color(0xFF5B4636);
      case ReadingBackground.dark:
        return const Color(0xFFE0E0E0);
      case ReadingBackground.highContrast:
        return Colors.white;
    }
  }
}