import 'package:hive_flutter/hive_flutter.dart';
import 'package:ramadan_project/features/khatmah/domain/entities/khatmah_entities.dart';

class KhatmahLocalDataSource {
  static const String _khatmahPlanBoxName = 'khatmah_plan';
  static const String _khatmahHistoryBoxName = 'khatmah_history';
  static const String _milestonesBoxName = 'khatmah_milestones';

  Box<KhatmahPlan>? _khatmahPlanBox;
  Box<KhatmahHistoryEntry>? _khatmahHistoryBox;
  Box<KhatmahMilestone>? _milestonesBox;

  Future<void> init() async {
    _khatmahPlanBox = await Hive.openBox<KhatmahPlan>(_khatmahPlanBoxName);
    _khatmahHistoryBox = await Hive.openBox<KhatmahHistoryEntry>(
      _khatmahHistoryBoxName,
    );
    _milestonesBox = await Hive.openBox<KhatmahMilestone>(_milestonesBoxName);
  }

  KhatmahPlan? getKhatmahPlan() {
    return _khatmahPlanBox?.get('current_plan');
  }

  Future<void> saveKhatmahPlan(KhatmahPlan plan) async {
    await _khatmahPlanBox?.put('current_plan', plan);
  }

  Future<void> deleteKhatmahPlan() async {
    await _khatmahPlanBox?.delete('current_plan');
  }

  List<KhatmahHistoryEntry> getKhatmahHistory() {
    return _khatmahHistoryBox?.values.toList() ?? [];
  }

  Future<void> addKhatmahHistoryEntry(KhatmahHistoryEntry entry) async {
    await _khatmahHistoryBox?.add(entry);
  }

  List<KhatmahMilestone> getKhatmahMilestones() {
    return _milestonesBox?.values.toList() ?? [];
  }

  Future<void> unlockMilestone(KhatmahMilestone milestone) async {
    await _milestonesBox?.put(milestone.id, milestone);
  }
}
