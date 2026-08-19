import 'package:flutter/material.dart';

enum ReadingBackground { white, sepia, dark, highContrast }

enum ReadingLayout { vertical, horizontal }

enum ReaderFormat { epub, pdf, txt }

enum EpubTextAlignment { left, justify }

enum PdfViewMode { single, continuous, facing }

enum PdfFitMode { width, page, custom }

enum PdfDarkMode { off, invertText, invertAll }

enum TxtFontMode { monospace, sansSerif }

enum TxtEncoding {
  utf8,
  iso88591,
  windows1252;

  String get label {
    switch (this) {
      case TxtEncoding.utf8:
        return 'UTF-8';
      case TxtEncoding.iso88591:
        return 'ISO-8859-1';
      case TxtEncoding.windows1252:
        return 'Windows-1252';
    }
  }
}

class EpubSettings {
  final String fontFamily;
  final double fontSize;
  final double lineHeight;
  final double sideMargin;
  final EpubTextAlignment alignment;
  final bool hyphenation;

  const EpubSettings({
    this.fontFamily = 'System',
    this.fontSize = 16.0,
    this.lineHeight = 1.6,
    this.sideMargin = 16.0,
    this.alignment = EpubTextAlignment.justify,
    this.hyphenation = false,
  });

  static const List<String> fontFamilies = [
    'System',
    'Serif',
    'Sans-Serif',
    'Georgia',
    'Merriweather',
    'OpenDyslexic',
  ];

  static const double minFontSize = 12.0;
  static const double maxFontSize = 32.0;
  static const double fontSizeStep = 1.0;
  static const int fontSizeDivisions = 20;

  static const double minLineHeight = 1.0;
  static const double maxLineHeight = 2.5;
  static const double lineHeightStep = 0.1;
  static const int lineHeightDivisions = 15;

  static const double minSideMargin = 0.0;
  static const double maxSideMargin = 64.0;
  static const double sideMarginStep = 1.0;
  static const int sideMarginDivisions = 64;

  EpubSettings copyWith({
    String? fontFamily,
    double? fontSize,
    double? lineHeight,
    double? sideMargin,
    EpubTextAlignment? alignment,
    bool? hyphenation,
  }) {
    return EpubSettings(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      sideMargin: sideMargin ?? this.sideMargin,
      alignment: alignment ?? this.alignment,
      hyphenation: hyphenation ?? this.hyphenation,
    );
  }
}

class PdfSettings {
  final PdfViewMode viewMode;
  final PdfFitMode fitMode;
  final double zoom;
  final bool autoCrop;
  final PdfDarkMode darkModeInversion;

  const PdfSettings({
    this.viewMode = PdfViewMode.continuous,
    this.fitMode = PdfFitMode.width,
    this.zoom = 1.0,
    this.autoCrop = true,
    this.darkModeInversion = PdfDarkMode.off,
  });

  static const double minZoom = 0.25;
  static const double maxZoom = 4.0;
  static const double zoomStep = 0.05;
  static const int zoomDivisions = 75;

  PdfSettings copyWith({
    PdfViewMode? viewMode,
    PdfFitMode? fitMode,
    double? zoom,
    bool? autoCrop,
    PdfDarkMode? darkModeInversion,
  }) {
    return PdfSettings(
      viewMode: viewMode ?? this.viewMode,
      fitMode: fitMode ?? this.fitMode,
      zoom: zoom ?? this.zoom,
      autoCrop: autoCrop ?? this.autoCrop,
      darkModeInversion: darkModeInversion ?? this.darkModeInversion,
    );
  }
}

class TxtSettings {
  final TxtFontMode fontMode;
  final double fontSize;
  final double lineHeight;
  final bool wordWrap;
  final int tabWidth;
  final TxtEncoding encoding;

  const TxtSettings({
    this.fontMode = TxtFontMode.sansSerif,
    this.fontSize = 16.0,
    this.lineHeight = 1.6,
    this.wordWrap = true,
    this.tabWidth = 4,
    this.encoding = TxtEncoding.utf8,
  });

  static const List<TxtFontMode> fontModes = [
    TxtFontMode.monospace,
    TxtFontMode.sansSerif,
  ];

  static const List<int> tabWidthOptions = [2, 4, 8];

  static const List<TxtEncoding> encodings = [
    TxtEncoding.utf8,
    TxtEncoding.iso88591,
    TxtEncoding.windows1252,
  ];

  static const double minFontSize = 12.0;
  static const double maxFontSize = 32.0;
  static const double fontSizeStep = 1.0;
  static const int fontSizeDivisions = 20;

  static const double minLineHeight = 1.0;
  static const double maxLineHeight = 2.5;
  static const double lineHeightStep = 0.1;
  static const int lineHeightDivisions = 15;

  TxtSettings copyWith({
    TxtFontMode? fontMode,
    double? fontSize,
    double? lineHeight,
    bool? wordWrap,
    int? tabWidth,
    TxtEncoding? encoding,
  }) {
    return TxtSettings(
      fontMode: fontMode ?? this.fontMode,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      wordWrap: wordWrap ?? this.wordWrap,
      tabWidth: tabWidth ?? this.tabWidth,
      encoding: encoding ?? this.encoding,
    );
  }
}

class ReaderSettings {
  final ReadingBackground background;
  final ReadingLayout layout;
  final bool blueLightEnabled;
  final double blueLightIntensity;
  final EpubSettings epub;
  final PdfSettings pdf;
  final TxtSettings txt;

  const ReaderSettings({
    this.background = ReadingBackground.white,
    this.layout = ReadingLayout.vertical,
    this.blueLightEnabled = false,
    this.blueLightIntensity = 0.3,
    this.epub = const EpubSettings(),
    this.pdf = const PdfSettings(),
    this.txt = const TxtSettings(),
  });

  static ReaderSettings recommendedFor(ReaderFormat format) {
    switch (format) {
      case ReaderFormat.epub:
        return const ReaderSettings(
          layout: ReadingLayout.horizontal,
          background: ReadingBackground.sepia,
        );
      case ReaderFormat.pdf:
        return const ReaderSettings(
          layout: ReadingLayout.vertical,
          background: ReadingBackground.white,
        );
      case ReaderFormat.txt:
        return const ReaderSettings(
          layout: ReadingLayout.vertical,
          background: ReadingBackground.sepia,
        );
    }
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

  ReaderSettings copyWith({
    ReadingBackground? background,
    ReadingLayout? layout,
    bool? blueLightEnabled,
    double? blueLightIntensity,
    EpubSettings? epub,
    PdfSettings? pdf,
    TxtSettings? txt,
  }) {
    return ReaderSettings(
      background: background ?? this.background,
      layout: layout ?? this.layout,
      blueLightEnabled: blueLightEnabled ?? this.blueLightEnabled,
      blueLightIntensity: blueLightIntensity ?? this.blueLightIntensity,
      epub: epub ?? this.epub,
      pdf: pdf ?? this.pdf,
      txt: txt ?? this.txt,
    );
  }
}