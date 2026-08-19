import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/services/update_service.dart';

class UpdateDialogs {
  UpdateDialogs._();

  static Future<void> checkAndPrompt(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text(AppStrings.checkingForUpdates)),
    );
    final update = await UpdateService.checkForUpdate();
    if (!context.mounted) return;
    if (update == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.upToDate)),
      );
    } else {
      await showUpdateDialog(context, update);
    }
  }

  static Future<void> showUpdateDialog(
    BuildContext context,
    UpdateInfo info,
  ) async {
    final shouldInstall = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${AppStrings.updateAvailable} v${info.version}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(AppStrings.updateAvailableMessage),
              if (info.releaseNotes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  AppStrings.releaseNotes,
                  style: Theme.of(ctx).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(info.releaseNotes),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.downloadAndInstall),
          ),
        ],
      ),
    );

    if (shouldInstall != true) return;
    if (!context.mounted) return;

    if (Platform.isAndroid) {
      await _downloadAndInstall(context, info.url);
    } else {
      await _openReleasePage(context);
    }
  }

  static Future<void> _downloadAndInstall(BuildContext context, String url) async {
    final progress = ValueNotifier<double>(0);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ValueListenableBuilder<double>(
        valueListenable: progress,
        builder: (ctx, value, _) => AlertDialog(
          title: const Text(AppStrings.downloadingUpdate),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: value > 0 ? value : null),
              const SizedBox(height: 8),
              Text('${(value * 100).round()}%'),
            ],
          ),
        ),
      ),
    );

    try {
      final path = await UpdateService.downloadApk(url, (received, total) {
        progress.value = total > 0 ? received / total : 0;
      });
      if (context.mounted) Navigator.of(context).pop();
      if (!context.mounted) return;
      await _openInstaller(context, path);
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.updateFailed}: $e')),
        );
      }
    }
  }

  static Future<void> _openInstaller(BuildContext context, String path) async {
    final result = await OpenFilex.open(
      path,
      type: 'application/vnd.android.package-archive',
    );
    if (!context.mounted) return;
    final message = switch (result.type) {
      ResultType.done => AppStrings.installerOpened,
      ResultType.fileNotFound => AppStrings.installFileNotFound,
      ResultType.noAppToOpen => AppStrings.noAppToInstall,
      ResultType.permissionDenied => AppStrings.installPermissionRequired,
      ResultType.error => AppStrings.installFailed,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static Future<void> _openReleasePage(BuildContext context) async {
    final opened = await launchUrl(
      Uri.parse(UpdateService.releasePageUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.couldNotOpenReleasePage)),
      );
    }
  }
}