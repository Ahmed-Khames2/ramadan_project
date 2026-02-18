import 'package:flutter/material.dart';
import 'package:ramadan_project/features/ramadan_worship/data/datasources/custom_tasks_datasource.dart';
import 'package:ramadan_project/features/ramadan_worship/data/datasources/worship_local_datasource.dart';
import 'package:ramadan_project/features/ramadan_worship/data/models/day_progress_model.dart';
import 'package:ramadan_project/features/ramadan_worship/domain/entities/day_progress.dart';

import 'package:ramadan_project/features/ramadan_worship/domain/repositories/worship_repository.dart';

class WorshipRepositoryImpl implements WorshipRepository {
  final WorshipLocalDataSource localDataSource;
  final CustomTasksDataSource customTasksDataSource;

  WorshipRepositoryImpl({
    required this.localDataSource,
    required this.customTasksDataSource,
  });

  @override
  Future<DayProgress> getDayProgress(DateTime date) async {
    final model = await localDataSource.getDayProgress(date);
    if (model != null) {
      return model.toEntity();
    }
    // Return empty progress if not found (Controller/Cubit will handle initialization of default tasks)
    return DayProgress(date: date, tasks: []);
  }

  @override
  Future<void> saveDayProgress(DayProgress progress) async {
    final model = DayProgressModel.fromEntity(progress);
    await localDataSource.saveDayProgress(model);
  }

  @override
  Future<int> getCurrentStreak() async {
    return await localDataSource.getCurrentStreak();
  }

  @override
  Future<int> getLongestStreak() async {
    return await localDataSource.getLongestStreak();
  }

  @override
  Future<void> updateStreaks({
    required int current,
    required int longest,
  }) async {
    await localDataSource.updateStreaks(current: current, longest: longest);
  }

  @override
  Future<List<String>> getCustomTasks() async {
    return await customTasksDataSource.getCustomTasks();
  }

  @override
  Future<void> addCustomTask(String title) async {
    await customTasksDataSource.addCustomTask(title);
  }

  @override
  Future<void> removeCustomTask(String title) async {
    await customTasksDataSource.removeCustomTask(title);
  }

  @override
  Future<List<DayProgress>> getMonthHistory(int year, int month) async {
    // This is a bit inefficient if we iterate all days, but with Hive keys it's fast enough for 30 days.
    final List<DayProgress> days = [];
    final daysInMonth = DateUtils.getDaysInMonth(year, month);

    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(year, month, i);
      final progress = await getDayProgress(date);
      // We only care about days that actually have data or are in the past/today
      if (progress.tasks.isNotEmpty || date.isBefore(DateTime.now())) {
        days.add(progress);
      }
    }
    return days;
  }
}
