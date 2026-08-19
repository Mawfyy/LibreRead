import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'data/services/reader_settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ReaderSettingsService.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const LibreReadApp());
}
