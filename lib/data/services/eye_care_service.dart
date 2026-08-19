import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReadingBackground { white, sepia, dark, highContrast }

class EyeCareService {
  EyeCareService._();

  static bool _blueLightFilterEnabled = false;
  static double _blueLightIntensity = 0.3;
  static ReadingBackground _readingBackground = ReadingBackground.white;
  static double _fontSize = 16.0;

  static bool get blueLightFilterEnabled => _blueLightFilterEnabled;
  static double get blueLightIntensity => _blueLightIntensity;
  static ReadingBackground get readingBackground => _readingBackground;
  static double get fontSize => _fontSize;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _blueLightFilterEnabled = prefs.getBool('eye_blue_light') ?? false;
    _blueLightIntensity = prefs.getDouble('eye_blue_light_intensity') ?? 0.3;
    _readingBackground = ReadingBackground.values[
        prefs.getInt('eye_reading_bg') ?? 0];
    _fontSize = prefs.getDouble('eye_font_size') ?? 16.0;
  }

  static Future<void> setBlueLightFilter(bool enabled) async {
    _blueLightFilterEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('eye_blue_light', enabled);
  }

  static Future<void> setBlueLightIntensity(double intensity) async {
    _blueLightIntensity = intensity;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('eye_blue_light_intensity', intensity);
  }

  static Future<void> setReadingBackground(ReadingBackground bg) async {
    _readingBackground = bg;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('eye_reading_bg', bg.index);
  }

  static Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('eye_font_size', size);
  }

  static Color get backgroundColor {
    switch (_readingBackground) {
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

  static Color get textColor {
    switch (_readingBackground) {
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

  static EpubTheme get epubTheme {
    switch (_readingBackground) {
      case ReadingBackground.white:
        return EpubTheme.light();
      case ReadingBackground.sepia:
        return EpubTheme.custom(
          backgroundDecoration: const BoxDecoration(color: Color(0xFFF5E6C8)),
          foregroundColor: const Color(0xFF5B4636),
        );
      case ReadingBackground.dark:
        return EpubTheme.dark();
      case ReadingBackground.highContrast:
        return EpubTheme.custom(
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          foregroundColor: Colors.white,
        );
    }
  }
}
