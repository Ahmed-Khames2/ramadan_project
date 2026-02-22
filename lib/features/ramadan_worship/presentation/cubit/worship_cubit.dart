import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/features/ramadan_worship/data/datasources/worship_tasks_constants.dart';
import 'package:ramadan_project/features/ramadan_worship/domain/entities/day_progress.dart';
import 'package:ramadan_project/features/ramadan_worship/domain/entities/worship_task.dart';
import 'package:ramadan_project/features/ramadan_worship/domain/repositories/worship_repository.dart';
import 'package:ramadan_project/features/ramadan_worship/presentation/cubit/worship_state.dart';

class WorshipCubit extends Cubit<WorshipState> {
  final WorshipRepository repository;

  WorshipCubit(this.repository) : super(const WorshipState());

  Future<void> loadDailyProgress() async {
    try {
      emit(state.copyWith(status: WorshipStatus.loading));

      final today = DateTime.now();

      // Load progress
      DayProgress progress = await repository.getDayProgress(today);

      // Load streaks
      var currentStreak = await repository.getCurrentStreak();
      final longestStreak = await repository.getLongestStreak();

      // Check if streak should be broken (if yesterday was not completed)
      if (currentStreak > 0) {
        final yesterday = today.subtract(const Duration(days: 1));
        final yesterdayProgress = await repository.getDayProgress(yesterday);

        // If yesterday has no record OR wasn't completed, reset streak
        // Note: IF yesterday has no record, tasks will be empty.
        if (yesterdayProgress.tasks.isEmpty ||
            !yesterdayProgress.isAllCompleted) {
          currentStreak = 0;
          await repository.updateStreaks(current: 0, longest: longestStreak);
        }
      }

      // If no tasks exist for today (new day), initialize with defaults + custom tasks
      if (progress.tasks.isEmpty) {
        final defaultTasks = List<WorshipTask>.from(
          WorshipTasksConstants.defaultTasks,
        );

        // Load custom tasks
        final customTaskTitles = await repository.getCustomTasks();
        final customTasks = customTaskTitles
            .map(
              (title) => WorshipTask(
                id: 'custom_${title.hashCode}',
                title: title,
                type: WorshipTaskType.checkbox,
                isEditable: true,
              ),
            )
            .toList();

        progress = progress.copyWith(
          date: today,
          tasks: [...defaultTasks, ...customTasks],
          isAllCompleted: false,
        );
        // Save initially to ensure record exists
        await repository.saveDayProgress(progress);
      }

      emit(
        state.copyWith(
          status: WorshipStatus.success,
          dayProgress: progress,
          currentStreak: currentStreak,
          longestStreak: longestStreak,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WorshipStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> addCustomTask(String title) async {
    if (state.dayProgress == null) return;

    try {
      // 1. Save to custom tasks definitions (for future days)
      await repository.addCustomTask(title);

      // 2. Add to CURRENT day's progress immediately
      final newTask = WorshipTask(
        id: 'custom_${title.hashCode}',
        title: title,
        type: WorshipTaskType.checkbox,
        isEditable: true,
      );

      final currentTasks = List<WorshipTask>.from(state.dayProgress!.tasks);
      // Avoid duplicates in current day if for some reason it exists
      if (!currentTasks.any((t) => t.title == title)) {
        currentTasks.add(newTask);

        final updatedProgress = state.dayProgress!.copyWith(
          tasks: currentTasks,
        );

        emit(state.copyWith(dayProgress: updatedProgress));
        await repository.saveDayProgress(updatedProgress);
      }
    } catch (e) {}
  }

  Future<void> removeCustomTask(WorshipTask task) async {
    if (state.dayProgress == null) return;

    try {
      // 1. Remove from definitions (for future days)
      await repository.removeCustomTask(task.title);

      // 2. Remove from CURRENT day's progress
      final currentTasks = List<WorshipTask>.from(state.dayProgress!.tasks);
      currentTasks.removeWhere((t) => t.id == task.id);

      final updatedProgress = state.dayProgress!.copyWith(tasks: currentTasks);
      emit(state.copyWith(dayProgress: updatedProgress));

      // Recalculate completion in case removing this task makes the day complete
      await _checkDailyCompletion(updatedProgress);

      await repository.saveDayProgress(updatedProgress);
    } catch (e) {}
  }

  Future<void> toggleTask(String taskId) async {
    if (state.dayProgress == null) return;

    try {
      final currentTasks = List<WorshipTask>.from(state.dayProgress!.tasks);
      final taskIndex = currentTasks.indexWhere((t) => t.id == taskId);

      if (taskIndex != -1) {
        final task = currentTasks[taskIndex];
        final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
        currentTasks[taskIndex] = updatedTask;

        final updatedProgress = state.dayProgress!.copyWith(
          tasks: currentTasks,
        );

        // Optimistic update
        emit(state.copyWith(dayProgress: updatedProgress));

        // Check for daily completion
        await _checkDailyCompletion(updatedProgress);

        // Save
        await repository.saveDayProgress(state.dayProgress!);
      }
    } catch (e) {
      // Revert or show error (for now just log)
    }
  }

  Future<void> updateTaskProgress(String taskId, int progress) async {
    if (state.dayProgress == null) return;

    try {
      final currentTasks = List<WorshipTask>.from(state.dayProgress!.tasks);
      final taskIndex = currentTasks.indexWhere((t) => t.id == taskId);

      if (taskIndex != -1) {
        final task = currentTasks[taskIndex];
        // Ensure progress doesn't exceed target or go below 0
        final newProgress = progress.clamp(0, task.target);

        final isCompleted = newProgress >= task.target;

        final updatedTask = task.copyWith(
          currentProgress: newProgress,
          isCompleted: isCompleted,
        );
        currentTasks[taskIndex] = updatedTask;

        final updatedProgress = state.dayProgress!.copyWith(
          tasks: currentTasks,
        );

        // Optimistic update
        emit(state.copyWith(dayProgress: updatedProgress));

        // Check for daily completion
        await _checkDailyCompletion(updatedProgress);

        // Save
        await repository.saveDayProgress(state.dayProgress!);
      }
    } catch (e) {}
  }

  Future<void> _checkDailyCompletion(DayProgress progress) async {
    final allCompleted = progress.tasks.every((t) => t.isCompleted);

    // If status changed from not completed to completed
    if (allCompleted && !progress.isAllCompleted) {
      final newCurrentStreak = state.currentStreak + 1;
      final newLongestStreak = newCurrentStreak > state.longestStreak
          ? newCurrentStreak
          : state.longestStreak;

      // Update streaks in Repo
      await repository.updateStreaks(
        current: newCurrentStreak,
        longest: newLongestStreak,
      );

      // Update Progress state
      final completedProgress = progress.copyWith(isAllCompleted: true);

      emit(
        state.copyWith(
          dayProgress: completedProgress,
          currentStreak: newCurrentStreak,
          longestStreak: newLongestStreak,
        ),
      );
    }
    // If status changed from completed to not completed (user unchecked something)
    else if (!allCompleted && progress.isAllCompleted) {
      final newCurrentStreak = (state.currentStreak - 1).clamp(0, 9999);
      // Longest streak remains same even if current breaks/decreases temporarily

      await repository.updateStreaks(
        current: newCurrentStreak,
        longest: state.longestStreak,
      );

      final uncompletedProgress = progress.copyWith(isAllCompleted: false);

      emit(
        state.copyWith(
          dayProgress: uncompletedProgress,
          currentStreak: newCurrentStreak,
        ),
      );
    }
  }
}
