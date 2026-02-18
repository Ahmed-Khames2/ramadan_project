// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worship_task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorshipTaskModelAdapter extends TypeAdapter<WorshipTaskModel> {
  @override
  final int typeId = 5;

  @override
  WorshipTaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorshipTaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      typeName: fields[2] as String,
      target: fields[3] as int,
      currentProgress: fields[4] as int,
      isCompleted: fields[5] as bool,
      isEditable: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WorshipTaskModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.typeName)
      ..writeByte(3)
      ..write(obj.target)
      ..writeByte(4)
      ..write(obj.currentProgress)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.isEditable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorshipTaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
