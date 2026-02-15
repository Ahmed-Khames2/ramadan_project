// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:hive/hive.dart';
import 'package:ramadan_project/features/khatmah/domain/entities/khatmah_entities.dart';

// part of 'khatmah_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************


class KhatmahPlanAdapter extends TypeAdapter<KhatmahPlan> {
  @override
  final int typeId = 2;

  @override
  KhatmahPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KhatmahPlan(
      startDate: fields[0] as DateTime,
      targetDays: fields[1] as int,
      restDaysEnabled: fields[2] as bool,
      restDays: (fields[3] as List).cast<int>(),
      currentProgressPage: fields[4] as int,
      isPaused: fields[5] as bool,
      lastReadAt: fields[6] as DateTime?,
      dailyPagesRead: (fields[7] as Map).cast<String, int>(),
      title: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, KhatmahPlan obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.targetDays)
      ..writeByte(2)
      ..write(obj.restDaysEnabled)
      ..writeByte(3)
      ..write(obj.restDays)
      ..writeByte(4)
      ..write(obj.currentProgressPage)
      ..writeByte(5)
      ..write(obj.isPaused)
      ..writeByte(6)
      ..write(obj.lastReadAt)
      ..writeByte(7)
      ..write(obj.dailyPagesRead)
      ..writeByte(8)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KhatmahPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class KhatmahHistoryEntryAdapter extends TypeAdapter<KhatmahHistoryEntry> {
  @override
  final int typeId = 3;

  @override
  KhatmahHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KhatmahHistoryEntry(
      startDate: fields[0] as DateTime,
      completionDate: fields[1] as DateTime,
      totalDays: fields[2] as int,
      title: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, KhatmahHistoryEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.completionDate)
      ..writeByte(2)
      ..write(obj.totalDays)
      ..writeByte(3)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KhatmahHistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class KhatmahMilestoneAdapter extends TypeAdapter<KhatmahMilestone> {
  @override
  final int typeId = 4;

  @override
  KhatmahMilestone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KhatmahMilestone(
      id: fields[0] as String,
      title: fields[1] as String,
      unlockedAt: fields[2] as DateTime,
      icon: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, KhatmahMilestone obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.unlockedAt)
      ..writeByte(3)
      ..write(obj.icon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KhatmahMilestoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
