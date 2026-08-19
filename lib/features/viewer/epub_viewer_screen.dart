import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import '../../data/models/recent_file.dart';
import '../../data/models/epub_bookmark.dart';
import '../../data/services/file_bytes_store.dart';
import '../../data/services/epub_bookmark_service.dart';
import '../../data/services/eye_care_service.dart';
import '../../data/services/reading_position_service.dart';
import '../../data/services/reading_layout_service.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/file_utils.dart';

class EpubViewerScreen extends StatefulWidget {
  final RecentFile file;

  const EpubViewerScreen({super.key, required this.file});

  @override
  State<EpubViewerScreen> createState() => _EpubViewerScreenState();
}

class _EpubViewerScreenState extends State<EpubViewerScreen>
    with WidgetsBindingObserver {
  late final EpubController _epubController;
  late final EpubSource _epubSource;
  List<EpubChapter> _chapters = [];
  double _progress = 0.0;
  String _currentCfi = '';
  String _currentChapterTitle = '';
  bool _isLoading = true;
  String? _initialCfi;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _epubController = EpubController();
    final bytes = _loadFileBytes();
    if (bytes == null) throw Exception('File not found');
    _epubSource = EpubSource.fromData(bytes);
    _restorePosition();
  }

  @override
  void dispose() {
    _saveCurrentPosition();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _saveCurrentPosition();
    }
  }

  Future<void> _restorePosition() async {
    final cfi = await ReadingPositionService.getCfi(widget.file.path);
    if (cfi != null && mounted) {
      setState(() => _initialCfi = cfi);
    }
  }

  void _saveCurrentPosition() {
    if (_currentCfi.isNotEmpty) {
      ReadingPositionService.savePosition(
        widget.file.path,
        _currentCfi,
        _progress,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = EyeCareService.backgroundColor;
    final isHorizontal = ReadingLayoutService.isHorizontal;
    final displaySettings = EpubDisplaySettings(
      fontSize: EyeCareService.fontSize.round(),
      theme: EyeCareService.epubTheme,
      flow: isHorizontal ? EpubFlow.paginated : EpubFlow.scrolled,
      snap: isHorizontal,
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          widget.file.name,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: AppStrings.bookmarks,
            onPressed: _showBookmarks,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: AppStrings.search,
            onPressed: _showSearch,
          ),
        ],
      ),
      drawer: _buildTocDrawer(),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.transparent,
          ),
          Expanded(child: _buildBody(displaySettings)),
        ],
      ),
    );
  }

  Widget _buildTocDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppStrings.tableOfContents,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _chapters.isEmpty
                  ? const Center(child: Text(AppStrings.chapters))
                  : ListView.builder(
                      itemCount: _chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = _chapters[index];
                        final isCurrent = chapter.href == _currentChapterTitle;
                        return ListTile(
                          title: Text(
                            chapter.title,
                            style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isCurrent ? Theme.of(context).colorScheme.primary : null,
                            ),
                          ),
                          dense: true,
                          onTap: () {
                            _epubController.display(cfi: chapter.href);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookmarks() async {
    final bookmarks = await EpubBookmarkService.getBookmarks(widget.file.path);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (ctx, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.bookmarks,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: AppStrings.addBookmark,
                    onPressed: () async {
                      final location = await _epubController.getCurrentLocation();
                      if (!mounted) return;
                      final bookmark = EpubBookmark(
                        cfi: location.startCfi,
                        chapterTitle: _currentChapterTitle,
                        progress: location.progress,
                        createdAt: DateTime.now(),
                      );
                      await EpubBookmarkService.addBookmark(widget.file.path, bookmark);
                      if (mounted) {
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bookmark added')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: bookmarks.isEmpty
                  ? const Center(child: Text(AppStrings.noBookmarks))
                  : ListView.separated(
                      controller: controller,
                      itemCount: bookmarks.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final bookmark = bookmarks[index];
                        final percent = (bookmark.progress * 100).toStringAsFixed(0);
                        return ListTile(
                          leading: const Icon(Icons.bookmark, size: 20),
                          title: Text(
                            bookmark.chapterTitle.isNotEmpty
                                ? bookmark.chapterTitle
                                : 'Position $percent%',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '$percent% · ${_formatDate(bookmark.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () async {
                              await EpubBookmarkService.removeBookmark(
                                widget.file.path,
                                bookmark.cfi,
                              );
                              if (mounted) {
                                if (ctx.mounted) Navigator.pop(ctx);
                              }
                              _showBookmarks();
                            },
                          ),
                          onTap: () {
                            _epubController.display(cfi: bookmark.cfi);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showSearch() {
    final searchController = TextEditingController();
    List<EpubSearchResult> results = [];
    bool hasSearched = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            expand: false,
            builder: (ctx, controller) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: AppStrings.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setModalState(() {
                            results = [];
                            hasSearched = false;
                          });
                        },
                      ),
                    ),
                    onSubmitted: (query) async {
                      if (query.isEmpty) return;
                      final searchResults = await _epubController.search(query: query);
                      if (ctx.mounted) {
                        setModalState(() {
                          results = searchResults;
                          hasSearched = true;
                        });
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: !hasSearched
                      ? const Center(child: Text('Type to search'))
                      : results.isEmpty
                          ? const Center(child: Text(AppStrings.noResults))
                          : ListView.separated(
                              controller: controller,
                              itemCount: results.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final result = results[index];
                                return ListTile(
                                  leading: const Icon(Icons.search, size: 20),
                                  title: _highlightText(
                                    result.excerpt,
                                    searchController.text,
                                  ),
                                  onTap: () {
                                    _epubController.display(cfi: result.cfi);
                                    Navigator.pop(ctx);
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _highlightText(String text, String query) {
    if (query.isEmpty) return Text(text);
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: const TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = index + query.length;
    }

    return Text.rich(TextSpan(children: spans, style: const TextStyle(fontSize: 13)));
  }

  Widget _buildBody(EpubDisplaySettings settings) {
    final viewer = EpubViewer(
      epubController: _epubController,
      epubSource: _epubSource,
      displaySettings: settings,
      initialCfi: _initialCfi,
      onChaptersLoaded: (loaded) {
        setState(() {
          _chapters = loaded;
          _isLoading = false;
        });
      },
      onRelocated: (location) {
        setState(() {
          _progress = location.progress;
          _currentCfi = location.startCfi;
        });
        _updateCurrentChapter();
        _saveCurrentPosition();
      },
    );

    return Stack(
      children: [
        viewer,
        if (_isLoading) const Center(child: CircularProgressIndicator()),
        if (ReadingLayoutService.isHorizontal) ...[
          Positioned(
            left: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: _NavArrowButton(
                icon: Icons.chevron_left,
                onTap: () => _epubController.prev(),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: _NavArrowButton(
                icon: Icons.chevron_right,
                onTap: () => _epubController.next(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Uint8List? _loadFileBytes() {
    if (FileUtils.isWebRef(widget.file.path)) {
      final id = FileUtils.getWebId(widget.file.path);
      return FileBytesStore.retrieve(id);
    }
    final file = File(widget.file.path);
    return file.readAsBytesSync();
  }

  void _updateCurrentChapter() {
    if (_chapters.isEmpty) return;
    for (final chapter in _chapters) {
      if (_currentCfi.contains(chapter.href) || chapter.href.contains(_currentCfi)) {
        setState(() => _currentChapterTitle = chapter.title);
        return;
      }
    }
  }
}

class _NavArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: Colors.white70, size: 28),
      ),
    );
  }
}
