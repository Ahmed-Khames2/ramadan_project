import 'package:equatable/equatable.dart';
import 'package:ramadan_project/features/ramadan_worship/domain/entities/day_progress.dart';

enum WorshipStatus { initial, loading, success, failure }

class WorshipState extends Equatable {
  final WorshipStatus status;
  final DayProgress? dayProgress;
  final int currentStreak;
  final int longestStreak;
  final String? errorMessage;

  const WorshipState({
    this.status = WorshipStatus.initial,
    this.dayProgress,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.errorMessage,
  });

  WorshipState copyWith({
    WorshipStatus? status,
    DayProgress? dayProgress,
    int? currentStreak,
    int? longestStreak,
    String? errorMessage,
  }) {
    return WorshipState(
      status: status ?? this.status,
      dayProgress: dayProgress ?? this.dayProgress,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    dayProgress,
    currentStreak,
    longestStreak,
    errorMessage,
  ];
}
