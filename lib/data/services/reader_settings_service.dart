import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reader_settings.dart';

class ReaderSettingsService {
  ReaderSettingsService._();

  static final Map<ReaderFormat, ReaderSettings> _settings = {};

  static ReaderSettings settingsFor(ReaderFormat format) =>
      _settings[format] ?? ReaderSettings.recommendedFor(format);

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
    final recommended = ReaderSettings.recommendedFor(format);
    return ReaderSettings(
      background: ReadingBackground.values[
          prefs.getInt('${prefix}_reading_bg') ??
              recommended.background.index],
      layout: ReadingLayout.values[prefs.getInt('${prefix}_layout') ??
          recommended.layout.index],
      blueLightEnabled: prefs.getBool('${prefix}_blue_light') ??
          recommended.blueLightEnabled,
      blueLightIntensity:
          prefs.getDouble('${prefix}_blue_light_intensity') ??
              recommended.blueLightIntensity,
      epub: _loadEpub(prefs, prefix),
      pdf: _loadPdf(prefs, prefix),
      txt: _loadTxt(prefs, prefix),
    );
  }

  static EpubSettings _loadEpub(SharedPreferences prefs, String prefix) {
    return EpubSettings(
      fontFamily: prefs.getString('${prefix}_epub_font_family') ?? 'System',
      fontSize: prefs.getDouble('${prefix}_epub_font_size') ?? 16.0,
      lineHeight: prefs.getDouble('${prefix}_epub_line_height') ?? 1.6,
      sideMargin: prefs.getDouble('${prefix}_epub_side_margin') ?? 16.0,
      alignment: EpubTextAlignment.values[
          prefs.getInt('${prefix}_epub_alignment') ?? 0],
      hyphenation: prefs.getBool('${prefix}_epub_hyphenation') ?? false,
    );
  }

  static PdfSettings _loadPdf(SharedPreferences prefs, String prefix) {
    return PdfSettings(
      viewMode:
          PdfViewMode.values[prefs.getInt('${prefix}_pdf_view_mode') ?? 0],
      fitMode: PdfFitMode.values[prefs.getInt('${prefix}_pdf_fit_mode') ?? 0],
      zoom: prefs.getDouble('${prefix}_pdf_zoom') ?? 1.0,
      autoCrop: prefs.getBool('${prefix}_pdf_auto_crop') ?? true,
      darkModeInversion: PdfDarkMode.values[
          prefs.getInt('${prefix}_pdf_dark_inversion') ?? 0],
    );
  }

  static TxtSettings _loadTxt(SharedPreferences prefs, String prefix) {
    return TxtSettings(
      fontMode:
          TxtFontMode.values[prefs.getInt('${prefix}_txt_font_mode') ?? 0],
      fontSize: prefs.getDouble('${prefix}_txt_font_size') ?? 16.0,
      lineHeight: prefs.getDouble('${prefix}_txt_line_height') ?? 1.6,
      wordWrap: prefs.getBool('${prefix}_txt_word_wrap') ?? true,
      tabWidth: prefs.getInt('${prefix}_txt_tab_width') ?? 4,
      encoding:
          TxtEncoding.values[prefs.getInt('${prefix}_txt_encoding') ?? 0],
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
    await prefs.setInt('${prefix}_layout', settings.layout.index);
    await prefs.setBool('${prefix}_blue_light', settings.blueLightEnabled);
    await prefs.setDouble(
      '${prefix}_blue_light_intensity',
      settings.blueLightIntensity,
    );
    await _saveEpub(prefs, prefix, settings.epub);
    await _savePdf(prefs, prefix, settings.pdf);
    await _saveTxt(prefs, prefix, settings.txt);
  }

  static Future<void> _saveEpub(
    SharedPreferences prefs,
    String prefix,
    EpubSettings settings,
  ) async {
    await prefs.setString('${prefix}_epub_font_family', settings.fontFamily);
    await prefs.setDouble('${prefix}_epub_font_size', settings.fontSize);
    await prefs.setDouble('${prefix}_epub_line_height', settings.lineHeight);
    await prefs.setDouble('${prefix}_epub_side_margin', settings.sideMargin);
    await prefs.setInt('${prefix}_epub_alignment', settings.alignment.index);
    await prefs.setBool('${prefix}_epub_hyphenation', settings.hyphenation);
  }

  static Future<void> _savePdf(
    SharedPreferences prefs,
    String prefix,
    PdfSettings settings,
  ) async {
    await prefs.setInt('${prefix}_pdf_view_mode', settings.viewMode.index);
    await prefs.setInt('${prefix}_pdf_fit_mode', settings.fitMode.index);
    await prefs.setDouble('${prefix}_pdf_zoom', settings.zoom);
    await prefs.setBool('${prefix}_pdf_auto_crop', settings.autoCrop);
    await prefs.setInt(
      '${prefix}_pdf_dark_inversion',
      settings.darkModeInversion.index,
    );
  }

  static Future<void> _saveTxt(
    SharedPreferences prefs,
    String prefix,
    TxtSettings settings,
  ) async {
    await prefs.setInt('${prefix}_txt_font_mode', settings.fontMode.index);
    await prefs.setDouble('${prefix}_txt_font_size', settings.fontSize);
    await prefs.setDouble('${prefix}_txt_line_height', settings.lineHeight);
    await prefs.setBool('${prefix}_txt_word_wrap', settings.wordWrap);
    await prefs.setInt('${prefix}_txt_tab_width', settings.tabWidth);
    await prefs.setInt('${prefix}_txt_encoding', settings.encoding.index);
  }

  static Future<void> reset(ReaderFormat format) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = format.name;
    await Future.wait([
      prefs.remove('${prefix}_reading_bg'),
      prefs.remove('${prefix}_layout'),
      prefs.remove('${prefix}_blue_light'),
      prefs.remove('${prefix}_blue_light_intensity'),
      prefs.remove('${prefix}_epub_font_family'),
      prefs.remove('${prefix}_epub_font_size'),
      prefs.remove('${prefix}_epub_line_height'),
      prefs.remove('${prefix}_epub_side_margin'),
      prefs.remove('${prefix}_epub_alignment'),
      prefs.remove('${prefix}_epub_hyphenation'),
      prefs.remove('${prefix}_pdf_view_mode'),
      prefs.remove('${prefix}_pdf_fit_mode'),
      prefs.remove('${prefix}_pdf_zoom'),
      prefs.remove('${prefix}_pdf_auto_crop'),
      prefs.remove('${prefix}_pdf_dark_inversion'),
      prefs.remove('${prefix}_txt_font_mode'),
      prefs.remove('${prefix}_txt_font_size'),
      prefs.remove('${prefix}_txt_line_height'),
      prefs.remove('${prefix}_txt_word_wrap'),
      prefs.remove('${prefix}_txt_tab_width'),
      prefs.remove('${prefix}_txt_encoding'),
    ]);
    _settings[format] = ReaderSettings.recommendedFor(format);
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