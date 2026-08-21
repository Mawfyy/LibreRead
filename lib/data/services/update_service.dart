import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateInfo {
  final String version;
  final String url;
  final String releaseNotes;

  const UpdateInfo({
    required this.version,
    required this.url,
    this.releaseNotes = '',
  });
}

class UpdateService {
  UpdateService._();

  static const String _latestReleaseApi =
      'https://api.github.com/repos/Mawfyy/LibreRead/releases/latest';

  static const String _cacheLatestVersionKey = 'updates_latest_version';
  static const String _cacheLatestUrlKey = 'updates_latest_url';
  static const String _cacheLatestNotesKey = 'updates_latest_notes';
  static const String _cacheLastCheckedKey = 'updates_last_checked_at';
  static const Duration _cacheTtl = Duration(hours: 1);

  static const MethodChannel _channel =
      MethodChannel('com.libre.read/signatures');

  static Future<String?> getInstalledAppSignature() async {
    try {
      return await _channel.invokeMethod('getInstalledAppSignature');
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getApkSignature(String apkPath) async {
    try {
      return await _channel.invokeMethod('getApkSignature', apkPath);
    } catch (_) {
      return null;
    }
  }

  static Future<UpdateInfo?> checkForUpdate({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();

    final cached = await _cachedUpdateIfNewer(prefs, packageInfo.version, forceRefresh);
    if (cached != null) return cached;

    try {
      final response = await http.get(
        Uri.parse(_latestReleaseApi),
        headers: {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'LibreRead',
        },
      );
      if (response.statusCode != 200) {
        return await _cachedUpdateIfNewer(prefs, packageInfo.version, false);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tag = data['tag_name'] as String?;
      if (tag == null) return null;

      final version = tag.replaceFirst(RegExp(r'^v'), '');
      String? apkUrl;
      for (final asset in (data['assets'] as List? ?? [])) {
        final assetMap = asset as Map<String, dynamic>;
        if ((assetMap['name'] as String? ?? '').endsWith('.apk')) {
          apkUrl = assetMap['browser_download_url'] as String?;
          break;
        }
      }
      if (apkUrl == null) return null;

      final update = UpdateInfo(
        version: version,
        url: apkUrl,
        releaseNotes: data['body'] as String? ?? '',
      );

      await _cacheUpdate(prefs, update);

      if (!_isNewer(version, packageInfo.version)) return null;
      return update;
    } catch (_) {
      return await _cachedUpdateIfNewer(prefs, packageInfo.version, false);
    }
  }

  static Future<UpdateInfo?> _cachedUpdateIfNewer(
    SharedPreferences prefs,
    String installedVersion,
    bool allowStale,
  ) async {
    final version = prefs.getString(_cacheLatestVersionKey);
    final url = prefs.getString(_cacheLatestUrlKey);
    if (version == null || url == null) return null;

    if (!allowStale) {
      final checkedAt = prefs.getInt(_cacheLastCheckedKey);
      if (checkedAt == null) return null;
      final cacheAge =
          DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(checkedAt));
      if (cacheAge > _cacheTtl) return null;
    }

    if (!_isNewer(version, installedVersion)) return null;
    return UpdateInfo(
      version: version,
      url: url,
      releaseNotes: prefs.getString(_cacheLatestNotesKey) ?? '',
    );
  }

  static Future<void> _cacheUpdate(SharedPreferences prefs, UpdateInfo update) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Future.wait([
      prefs.setString(_cacheLatestVersionKey, update.version),
      prefs.setString(_cacheLatestUrlKey, update.url),
      prefs.setString(_cacheLatestNotesKey, update.releaseNotes),
      prefs.setInt(_cacheLastCheckedKey, now),
    ]);
  }

  static bool _isNewer(String latest, String installed) {
    final latestParts = latest.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final installedParts =
        installed.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final length = latestParts.length > installedParts.length
        ? latestParts.length
        : installedParts.length;
    for (var i = 0; i < length; i++) {
      final a = i < latestParts.length ? latestParts[i] : 0;
      final b = i < installedParts.length ? installedParts[i] : 0;
      if (a > b) return true;
      if (a < b) return false;
    }
    return false;
  }

  static Future<String> downloadApk(
    String url,
    void Function(int received, int total)? onProgress,
  ) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/libre_read_update.apk');

    final request = http.Request('GET', Uri.parse(url));
    final streamed = await request.send();
    if (streamed.statusCode != 200) {
      throw Exception('Download failed: HTTP ${streamed.statusCode}');
    }

    final total = streamed.contentLength ?? 0;
    var received = 0;
    final sink = file.openWrite();
    await for (final chunk in streamed.stream) {
      received += chunk.length;
      sink.add(chunk);
      if (total > 0) onProgress?.call(received, total);
    }
    await sink.close();
    return file.path;
  }

  static String get releasePageUrl =>
      'https://github.com/Mawfyy/LibreRead/releases/latest';
}