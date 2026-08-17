// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_file.dart';

class RecentFileAdapter extends TypeAdapter<RecentFile> {
  @override
  final int typeId = 1;

  @override
  RecentFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecentFile(
      name: fields[0] as String,
      path: fields[1] as String,
      type: fields[2] as FileType,
      lastOpened: fields[3] as DateTime,
      lastPage: fields[4] as int?,
      fileSize: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RecentFile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.lastOpened)
      ..writeByte(4)
      ..write(obj.lastPage)
      ..writeByte(5)
      ..write(obj.fileSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FileTypeAdapter extends TypeAdapter<FileType> {
  @override
  final int typeId = 0;

  @override
  FileType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FileType.pdf;
      case 1:
        return FileType.docx;
      case 2:
        return FileType.epub;
      default:
        return FileType.pdf;
    }
  }

  @override
  void write(BinaryWriter writer, FileType obj) {
    switch (obj) {
      case FileType.pdf:
        writer.writeByte(0);
        break;
      case FileType.docx:
        writer.writeByte(1);
        break;
      case FileType.epub:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
