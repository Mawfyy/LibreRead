import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reader_settings.dart';

class ReaderSettingsService {
  ReaderSettingsService._();

  static final Map<ReaderFormat, ReaderSettings> _settings = {};

  static ReaderSettings settingsFor(ReaderFormat format) =>
      _settings[format] ?? ReaderSettings.defaults;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    for (final format in ReaderFormat.values) {
      _settings[format] = _loadFromPrefs(prefs, format);
    }
  }

  static ReaderSettings _loadFromPrefs(
    SharedPreferences prefs,
    ReaderFormat format,
  ) {
    final prefix = format.name;
    return ReaderSettings(
      background: ReadingBackground.values[
          prefs.getInt('${prefix}_reading_bg') ?? 0],
      fontSize: prefs.getDouble('${prefix}_font_size') ?? 16.0,
      blueLightEnabled: prefs.getBool('${prefix}_blue_light') ?? false,
      blueLightIntensity:
          prefs.getDouble('${prefix}_blue_light_intensity') ?? 0.3,
      layout: ReadingLayout.values[prefs.getInt('${prefix}_layout') ?? 0],
    );
  }

  static Future<void> update(
    ReaderFormat format,
    ReaderSettings settings,
  ) async {
    _settings[format] = settings;
    final prefs = await SharedPreferences.getInstance();
    final prefix = format.name;
    await prefs.setInt('${prefix}_reading_bg', settings.background.index);
    await prefs.setDouble('${prefix}_font_size', settings.fontSize);
    await prefs.setBool('${prefix}_blue_light', settings.blueLightEnabled);
    await prefs.setDouble(
      '${prefix}_blue_light_intensity',
      settings.blueLightIntensity,
    );
    await prefs.setInt('${prefix}_layout', settings.layout.index);
  }

  static EpubTheme epubThemeFor(ReaderSettings settings) {
    switch (settings.background) {
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