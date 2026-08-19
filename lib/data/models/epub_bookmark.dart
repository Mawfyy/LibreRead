import 'dart:convert';

class EpubBookmark {
  final String cfi;
  final String chapterTitle;
  final double progress;
  final DateTime createdAt;

  EpubBookmark({
    required this.cfi,
    required this.chapterTitle,
    required this.progress,
    required this.createdAt,
  });

  String toJsonString() => jsonEncode({
    'cfi': cfi,
    'chapterTitle': chapterTitle,
    'progress': progress,
    'createdAt': createdAt.toIso8601String(),
  });

  factory EpubBookmark.fromJson(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return EpubBookmark(
      cfi: map['cfi'] as String,
      chapterTitle: map['chapterTitle'] as String,
      progress: (map['progress'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
