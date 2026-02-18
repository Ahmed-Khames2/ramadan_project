// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProgressModelAdapter extends TypeAdapter<UserProgressModel> {
  @override
  final int typeId = 0;

  @override
  UserProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgressModel(
      lastReadPage: fields[0] as int?,
      lastReadAyahId: fields[1] as int?,
      bookmarks: (fields[2] as List?)?.cast<int>(),
      favorites: (fields[3] as List?)?.cast<int>(),
      targetDays: fields[4] as int?,
      startDate: fields[5] as DateTime?,
      scrollOffset: fields[6] as double?,
      lastReadSurahNumber: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgressModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.lastReadPage)
      ..writeByte(1)
      ..write(obj.lastReadAyahId)
      ..writeByte(2)
      ..write(obj.bookmarks)
      ..writeByte(3)
      ..write(obj.favorites)
      ..writeByte(4)
      ..write(obj.targetDays)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.scrollOffset)
      ..writeByte(7)
      ..write(obj.lastReadSurahNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
