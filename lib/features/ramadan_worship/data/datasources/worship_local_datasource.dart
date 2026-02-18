import 'package:hive/hive.dart';
import 'package:ramadan_project/features/ramadan_worship/data/models/day_progress_model.dart';
import 'package:ramadan_project/features/ramadan_worship/data/models/worship_task_model.dart';
import 'package:ramadan_project/features/ramadan_worship/domain/entities/worship_task.dart';

abstract class WorshipLocalDataSource {
  Future<void> init();
  Future<DayProgressModel?> getDayProgress(DateTime date);
  Future<void> saveDayProgress(DayProgressModel progress);
  Future<int> getCurrentStreak();
  Future<int> getLongestStreak();
  Future<void> updateStreaks({required int current, required int longest});
}

class WorshipLocalDataSourceImpl implements WorshipLocalDataSource {
  static const String _boxName = 'ramadan_worship_box';
  static const String _streakKey = 'streak_data';

  late Box _box;

  @override
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  String _getDateKey(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  @override
  Future<DayProgressModel?> getDayProgress(DateTime date) async {
    final key = _getDateKey(date);
    return _box.get(key) as DayProgressModel?;
  }

  @override
  Future<void> saveDayProgress(DayProgressModel progress) async {
    final key = _getDateKey(progress.date);
    await _box.put(key, progress);
  }

  @override
  Future<int> getCurrentStreak() async {
    final data = _box.get(
      _streakKey,
      defaultValue: {'current': 0, 'longest': 0},
    );
    if (data is Map) {
      return data['current'] as int? ?? 0;
    }
    return 0;
  }

  @override
  Future<int> getLongestStreak() async {
    final data = _box.get(
      _streakKey,
      defaultValue: {'current': 0, 'longest': 0},
    );
    if (data is Map) {
      return data['longest'] as int? ?? 0;
    }
    return 0;
  }

  @override
  Future<void> updateStreaks({
    required int current,
    required int longest,
  }) async {
    await _box.put(_streakKey, {'current': current, 'longest': longest});
  }
}
