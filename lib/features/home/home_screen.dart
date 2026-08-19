import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/file_utils.dart';
import '../../data/models/recent_file.dart';
import '../../data/services/file_picker_service.dart';
import '../../data/services/file_bytes_store.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/cover_cache_service.dart';
import '../../data/services/update_service.dart';
import '../viewer/viewer_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/widgets/update_dialog.dart';
import 'widgets/file_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RecentFile> _recentFiles = [];

  @override
  void initState() {
    super.initState();
    StorageService.init().then((_) => _loadFiles());
    _checkForUpdates();
  }

  void _checkForUpdates() async {
    final update = await UpdateService.checkForUpdate();
    if (!mounted || update == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppStrings.updateAvailable} v${update.version}'),
        action: SnackBarAction(
          label: AppStrings.downloadAndInstall,
          onPressed: () => UpdateDialogs.showUpdateDialog(context, update),
        ),
      ),
    );
  }

  void _loadFiles() {
    setState(() {
      _recentFiles = StorageService.getRecentFiles();
    });
    _extractMissingCovers();
  }

  void _extractMissingCovers() {
    for (final file in _recentFiles) {
      if (file.type == FileType.epub &&
          file.coverPath == null &&
          file.fileSize < 10 * 1024 * 1024 &&
          !FileUtils.isWebRef(file.path)) {
        _extractCover(file);
      }
    }
  }

  void _extractCover(RecentFile file) async {
    final coverPath = await CoverCacheService.extractAndCacheCover(file.path);
    if (coverPath != null && mounted) {
      await StorageService.addOrUpdateFile(
        RecentFile(
          name: file.name,
          path: file.path,
          type: file.type,
          lastOpened: file.lastOpened,
          fileSize: file.fileSize,
          coverPath: coverPath,
        ),
      );
      if (mounted) _loadFiles();
    }
  }

  Future<void> _openFile() async {
    final file = await FilePickerService.pickAndOpenFile();
    if (file != null && mounted) {
      _loadFiles();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViewerScreen(file: file),
        ),
      ).then((_) => _loadFiles());
    }
  }

  void _openExistingFile(RecentFile file) async {
    if (FileUtils.isWebRef(file.path)) {
      final id = FileUtils.getWebId(file.path);
      if (FileBytesStore.retrieve(id) == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File is no longer in memory. Open it again.')),
          );
        }
        return;
      }
    }

    await StorageService.addOrUpdateFile(
      RecentFile(
        name: file.name,
        path: file.path,
        type: file.type,
        lastOpened: DateTime.now(),
        fileSize: file.fileSize,
        coverPath: file.coverPath,
      ),
    );
    _loadFiles();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViewerScreen(file: file),
        ),
      ).then((_) => _loadFiles());
    }
  }

  void _deleteFile(RecentFile file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteFile),
        content: Text('Delete "${file.name}" from history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (FileUtils.isWebRef(file.path)) {
        FileBytesStore.remove(FileUtils.getWebId(file.path));
      }
      await StorageService.removeFile(file.path);
      _loadFiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _recentFiles.isEmpty ? _buildEmptyState() : _buildFileList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openFile,
        tooltip: AppStrings.openFile,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noFiles,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.noFilesMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: _recentFiles.length,
      itemBuilder: (context, index) {
        final file = _recentFiles[index];
        return FileCard(
          file: file,
          onTap: () => _openExistingFile(file),
          onLongPress: () => _deleteFile(file),
        );
      },
    );
  }
}
