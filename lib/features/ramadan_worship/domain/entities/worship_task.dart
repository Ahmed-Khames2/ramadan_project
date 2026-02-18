import 'package:equatable/equatable.dart';

enum WorshipTaskType {
  prayer, // For 5 daily prayers
  checkbox, // For Taraweeh, Qiyam, Adhkar, Dua
  count, // For Quran pages, Tasbeeh, Istighfar
}

class WorshipTask extends Equatable {
  final String id;
  final String title;
  final WorshipTaskType type;
  final int target; // For count-based tasks (e.g., 100 Tasbeeh, 20 Pages)
  final int currentProgress;
  final bool isCompleted;
  final bool isEditable; // Can the user change the target?

  const WorshipTask({
    required this.id,
    required this.title,
    required this.type,
    this.target = 1,
    this.currentProgress = 0,
    this.isCompleted = false,
    this.isEditable = false,
  });

  WorshipTask copyWith({
    String? id,
    String? title,
    WorshipTaskType? type,
    int? target,
    int? currentProgress,
    bool? isCompleted,
    bool? isEditable,
  }) {
    return WorshipTask(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      target: target ?? this.target,
      currentProgress: currentProgress ?? this.currentProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      isEditable: isEditable ?? this.isEditable,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    type,
    target,
    currentProgress,
    isCompleted,
    isEditable,
  ];
}
