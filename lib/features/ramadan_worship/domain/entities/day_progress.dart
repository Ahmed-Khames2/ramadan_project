import 'package:equatable/equatable.dart';
import 'package:ramadan_project/features/ramadan_worship/domain/entities/worship_task.dart';

class DayProgress extends Equatable {
  final DateTime date;
  final List<WorshipTask> tasks;
  final bool isAllCompleted;

  const DayProgress({
    required this.date,
    required this.tasks,
    this.isAllCompleted = false,
  });

  // Helper to ensure comparison ignores time
  String get dateKey => "${date.year}-${date.month}-${date.day}";

  DayProgress copyWith({
    DateTime? date,
    List<WorshipTask>? tasks,
    bool? isAllCompleted,
  }) {
    return DayProgress(
      date: date ?? this.date,
      tasks: tasks ?? this.tasks,
      isAllCompleted: isAllCompleted ?? this.isAllCompleted,
    );
  }

  @override
  List<Object?> get props => [dateKey, tasks, isAllCompleted];
}
