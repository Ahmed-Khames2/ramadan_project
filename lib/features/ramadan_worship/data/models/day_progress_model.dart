import 'package:hive/hive.dart';
import 'package:ramadan_project/features/ramadan_worship/data/models/worship_task_model.dart';
import 'package:ramadan_project/features/ramadan_worship/domain/entities/day_progress.dart';

part 'day_progress_model.g.dart';

@HiveType(typeId: 6)
class DayProgressModel extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final List<WorshipTaskModel> tasks;

  @HiveField(2)
  final bool isAllCompleted;

  DayProgressModel({
    required this.date,
    required this.tasks,
    required this.isAllCompleted,
  });

  factory DayProgressModel.fromEntity(DayProgress progress) {
    return DayProgressModel(
      date: progress.date,
      tasks: progress.tasks.map((t) => WorshipTaskModel.fromEntity(t)).toList(),
      isAllCompleted: progress.isAllCompleted,
    );
  }

  DayProgress toEntity() {
    return DayProgress(
      date: date,
      tasks: tasks.map((t) => t.toEntity()).toList(),
      isAllCompleted: isAllCompleted,
    );
  }
}
