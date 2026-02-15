import 'package:ramadan_project/features/khatmah/domain/entities/khatmah_entities.dart';

abstract class KhatmahRepository {
  KhatmahPlan? getKhatmahPlan();
  Future<void> saveKhatmahPlan(KhatmahPlan plan);
  Future<void> deleteKhatmahPlan();

  List<KhatmahHistoryEntry> getKhatmahHistory();
  Future<void> addKhatmahHistoryEntry(KhatmahHistoryEntry entry);

  List<KhatmahMilestone> getKhatmahMilestones();
  Future<void> unlockMilestone(KhatmahMilestone milestone);

  Future<void> saveKhatamPlanLegacy(int targetDays, DateTime startDate);
}
