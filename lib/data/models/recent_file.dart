import 'package:hive_ce/hive.dart';

part 'recent_file.g.dart';

@HiveType(typeId: 0)
enum FileType {
  @HiveField(0)
  pdf,

  @HiveField(1)
  docx,

  @HiveField(2)
  epub,
}

@HiveType(typeId: 1)
class RecentFile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String path;

  @HiveField(2)
  FileType type;

  @HiveField(3)
  DateTime lastOpened;

  @HiveField(4)
  int? lastPage;

  @HiveField(5)
  int fileSize;

  RecentFile({
    required this.name,
    required this.path,
    required this.type,
    required this.lastOpened,
    this.lastPage,
    this.fileSize = 0,
  });

  String get typeLabel {
    switch (type) {
      case FileType.pdf:
        return 'PDF';
      case FileType.docx:
        return 'Word';
      case FileType.epub:
        return 'EPUB';
    }
  }
}
