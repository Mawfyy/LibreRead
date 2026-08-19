import 'dart:convert';

enum FileType { epub, txt, pdf }

class RecentFile {
  final String name;
  final String path;
  final FileType type;
  final DateTime lastOpened;
  final int? lastPage;
  final int fileSize;
  final String? coverPath;

  RecentFile({
    required this.name,
    required this.path,
    required this.type,
    required this.lastOpened,
    this.lastPage,
    this.fileSize = 0,
    this.coverPath,
  });

  String get typeLabel {
    switch (type) {
      case FileType.epub:
        return 'EPUB';
      case FileType.txt:
        return 'Text';
      case FileType.pdf:
        return 'PDF';
    }
  }

  String toJsonString() => jsonEncode({
    'name': name,
    'path': path,
    'type': type.index,
    'lastOpened': lastOpened.toIso8601String(),
    'lastPage': lastPage,
    'fileSize': fileSize,
    'coverPath': coverPath,
  });

  factory RecentFile.fromJson(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return RecentFile(
      name: map['name'] as String,
      path: map['path'] as String,
      type: FileType.values[map['type'] as int],
      lastOpened: DateTime.parse(map['lastOpened'] as String),
      lastPage: map['lastPage'] as int?,
      fileSize: (map['fileSize'] as num?)?.toInt() ?? 0,
      coverPath: map['coverPath'] as String?,
    );
  }
}
