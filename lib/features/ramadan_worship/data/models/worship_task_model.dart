import 'package:hive/hive.dart';
import 'package:ramadan_project/features/ramadan_worship/domain/entities/worship_task.dart';

part 'worship_task_model.g.dart';

@HiveType(typeId: 5)
class WorshipTaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String typeName; // Storing enum as String for simplicity

  @HiveField(3)
  final int target;

  @HiveField(4)
  final int currentProgress;

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final bool isEditable;

  WorshipTaskModel({
    required this.id,
    required this.title,
    required this.typeName,
    required this.target,
    required this.currentProgress,
    required this.isCompleted,
    required this.isEditable,
  });

  factory WorshipTaskModel.fromEntity(WorshipTask task) {
    return WorshipTaskModel(
      id: task.id,
      title: task.title,
      typeName: task.type.name,
      target: task.target,
      currentProgress: task.currentProgress,
      isCompleted: task.isCompleted,
      isEditable: task.isEditable,
    );
  }

  WorshipTask toEntity() {
    return WorshipTask(
      id: id,
      title: title,
      type: WorshipTaskType.values.firstWhere(
        (e) => e.name == typeName,
        orElse: () => WorshipTaskType.checkbox,
      ),
      target: target,
      currentProgress: currentProgress,
      isCompleted: isCompleted,
      isEditable: isEditable,
    );
  }
}
