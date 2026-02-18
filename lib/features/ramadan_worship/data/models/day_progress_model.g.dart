// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DayProgressModelAdapter extends TypeAdapter<DayProgressModel> {
  @override
  final int typeId = 6;

  @override
  DayProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayProgressModel(
      date: fields[0] as DateTime,
      tasks: (fields[1] as List).cast<WorshipTaskModel>(),
      isAllCompleted: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DayProgressModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.tasks)
      ..writeByte(2)
      ..write(obj.isAllCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
