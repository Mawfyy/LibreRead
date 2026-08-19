# AGENTS.md

Instructions for AI assistants working on LibreRead.

## Project Overview

LibreRead is a cross-platform Flutter document reader app (EPUB, PDF, TXT). Written in Dart, targets Android, Linux, Web, and Windows.

## Build & Run

```bash
flutter pub get          # Install dependencies
flutter run              # Run in debug mode
flutter build apk --release  # Build Android APK
```

## Code Analysis & Linting

```bash
flutter analyze          # Run Dart static analysis
```

Uses `flutter_lints` via `analysis_options.yaml`. No custom lint rules.

## Testing

```bash
flutter test             # Run all tests
```

Uses `flutter_test`. Current test coverage is minimal (placeholder only). Always run `flutter test` after making changes.

## Architecture

Three-layer structure under `lib/`:

```
lib/
├── core/         # Constants (colors, strings), theme, utilities
├── data/         # Models and services (all static classes, SharedPreferences-based)
└── features/     # UI screens organized by feature (home, viewer, settings)
```

- **State management:** `StatefulWidget` + `setState()` (no Provider/Bloc/Riverpod)
- **Persistence:** `shared_preferences` only (no database)
- **Web support:** Special `FileBytesStore` in-memory path for web compatibility

## Code Conventions

- Follow existing Dart/Flutter style and naming conventions
- Keep services as static classes (matching existing pattern)
- String constants go in `lib/core/constants/app_strings.dart`
- Color constants go in `lib/core/constants/app_colors.dart`
- Feature screens go in `lib/features/<feature_name>/`
- Widgets specific to a feature go in `lib/features/<feature>/widgets/`
- No comments unless requested
- Commit messages: conventional commits style (e.g. `feat:`, `fix:`, `docs:`)
