import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'data/services/eye_care_service.dart';
import 'data/services/reading_layout_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EyeCareService.init();
  await ReadingLayoutService.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const LibreReadApp());
}
