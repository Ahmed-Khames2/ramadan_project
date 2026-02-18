import 'package:ramadan_project/features/ramadan_worship/domain/entities/day_progress.dart';

abstract class WorshipRepository {
  /// Loads the progress for a specific date.
  /// If no data exists for that date, it should return a fresh DayProgress.
  Future<DayProgress> getDayProgress(DateTime date);

  /// Saves the updated progress for a day.
  Future<void> saveDayProgress(DayProgress progress);

  /// Gets the current streak count.
  Future<int> getCurrentStreak();

  /// Gets the longest streak count recorded.
  Future<int> getLongestStreak();

  /// Updates the streak counts.
  Future<void> updateStreaks({required int current, required int longest});

  /// Resets daily tasks (usually handled by logic, but repo might expose reset mechanism if needed).
  /// For now, logic will handle "fresh" DayProgress creation.

  // Custom Tasks
  Future<List<String>> getCustomTasks();
  Future<void> addCustomTask(String title);
  Future<void> removeCustomTask(String title);

  // History
  Future<List<DayProgress>> getMonthHistory(int year, int month);
}
