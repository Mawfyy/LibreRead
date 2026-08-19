# AGENTS.md

Instructions for AI assistants working on LibreRead.

## Project Overview

LibreRead is an Android-only Flutter document reader app (EPUB, PDF, TXT). Written in Dart, targets Android.

## Build & Run

```bash
flutter pub get          # Install dependencies
flutter run              # Run in debug mode
flutter build apk --release  # Build Android APK (signed with release keystore)
```

## Android Release Signing

Release builds are signed with a persistent keystore at `android/app/libre_read_keystore.jks` (alias `libre_read`), configured via `android/key.properties`. Both files are gitignored — never commit them.

- `android/app/build.gradle` reads `key.properties` and signs `release` with the release keystore; if `key.properties` is missing it falls back to the debug key.
- CI (`/.github/workflows/build.yml`) decodes the keystore from the `ANDROID_KEYSTORE_B64` secret into `$RUNNER_TEMP` and writes `key.properties` there.
- Required GitHub secrets: `ANDROID_KEYSTORE_B64` (base64 of the `.jks`), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`.
- PKCS12 keystores do not support a separate key password, so `keyPassword` must equal `storePassword` in `key.properties`.
- Do NOT regenerate the keystore: changing the signing key makes existing installs unable to update (signature mismatch), requiring a full uninstall/reinstall.

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

## Code Conventions

- Follow existing Dart/Flutter style and naming conventions
- Keep services as static classes (matching existing pattern)
- String constants go in `lib/core/constants/app_strings.dart`
- Color constants go in `lib/core/constants/app_colors.dart`
- Feature screens go in `lib/features/<feature_name>/`
- Widgets specific to a feature go in `lib/features/<feature>/widgets/`
- No comments unless requested
- Commit messages: conventional commits style (e.g. `feat:`, `fix:`, `docs:`)
