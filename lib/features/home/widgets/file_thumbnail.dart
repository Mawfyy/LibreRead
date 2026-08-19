import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/recent_file.dart';

class FileThumbnail extends StatelessWidget {
  final RecentFile file;

  const FileThumbnail({super.key, required this.file});

  Color _getTypeColor() {
    switch (file.type) {
      case FileType.epub:
        return AppColors.epubColor;
      case FileType.txt:
        return AppColors.txtColor;
      case FileType.pdf:
        return AppColors.pdfColor;
    }
  }

  IconData _getTypeIcon() {
    switch (file.type) {
      case FileType.epub:
        return Icons.menu_book;
      case FileType.txt:
        return Icons.text_snippet;
      case FileType.pdf:
        return Icons.picture_as_pdf;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();

    if (file.coverPath != null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.file(
          File(file.coverPath!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(typeColor),
        ),
      );
    }

    return _buildPlaceholder(typeColor);
  }

  Widget _buildPlaceholder(Color typeColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getTypeIcon(), size: 48, color: typeColor.withValues(alpha: 0.7)),
            const SizedBox(height: 8),
            Text(
              file.typeLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: typeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
