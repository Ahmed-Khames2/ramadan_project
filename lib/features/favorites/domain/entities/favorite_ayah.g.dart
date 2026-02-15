// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_ayah.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteAyahAdapter extends TypeAdapter<FavoriteAyah> {
  @override
  final int typeId = 1;

  @override
  FavoriteAyah read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteAyah(
      surahNumber: fields[0] as int,
      ayahNumber: fields[1] as int,
      globalAyahNumber: fields[2] as int,
      text: fields[3] as String,
      surahName: fields[4] as String,
      addedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteAyah obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.surahNumber)
      ..writeByte(1)
      ..write(obj.ayahNumber)
      ..writeByte(2)
      ..write(obj.globalAyahNumber)
      ..writeByte(3)
      ..write(obj.text)
      ..writeByte(4)
      ..write(obj.surahName)
      ..writeByte(5)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteAyahAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
