# LibreRead

A modern EPUB, PDF & text reader built with Flutter.

## Screenshot

<!-- Add your screenshot here: place a .png in screenshots/ and uncomment the line below -->
<img width="720" height="1612" alt="image" src="https://github.com/user-attachments/assets/8cfe5ed5-a5be-4823-beae-be0a583ea474" />
<img width="720" height="1612" alt="image" src="https://github.com/user-attachments/assets/39ba228e-ea53-419f-9eb7-04911527fb75" />


## Features

- **EPUB Viewer** — Table of contents, bookmarks, full-text search, reading progress, navigation arrows
- **PDF Viewer** — Pinch-to-zoom with smooth page rendering
- **Plain Text Reader** — Scrollable, selectable text with copy/paste support
- **Eye Care** — Blue light filter (adjustable intensity), 4 reading backgrounds (white, sepia, dark, high contrast), adjustable font size
- **Cover Art** — Automatic EPUB cover extraction and caching
- **Recent Files** — History of up to 50 opened files with thumbnails
- **Themes** — Light, Dark, and System modes
- **Android Only** — Targets Android

## Supported Formats

| Format | Extension |
| ------ | --------- |
| EPUB   | `.epub`   |
| PDF    | `.pdf`    |
| Text   | `.txt`    |

## Getting Started

### Prerequisites

- Flutter >= 3.32.0
- Dart SDK >= 3.8.0

### Run

```bash
flutter pub get
flutter run
```

## Building

```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## License

MIT
