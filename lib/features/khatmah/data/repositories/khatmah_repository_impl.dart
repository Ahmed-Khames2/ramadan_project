import 'package:ramadan_project/data/models/user_progress_model.dart';
import 'package:ramadan_project/features/khatmah/data/datasources/khatmah_local_datasource.dart';
import 'package:ramadan_project/features/khatmah/domain/entities/khatmah_entities.dart';
import 'package:ramadan_project/features/khatmah/domain/repositories/khatmah_repository.dart';
import 'package:ramadan_project/features/quran/data/datasources/quran_local_datasource.dart';

class KhatmahRepositoryImpl implements KhatmahRepository {
  final KhatmahLocalDataSource localDataSource;
  final QuranLocalDataSource quranLocalDataSource;

  KhatmahRepositoryImpl({
    required this.localDataSource,
    required this.quranLocalDataSource,
  });

  @override
  KhatmahPlan? getKhatmahPlan() => localDataSource.getKhatmahPlan();

  @override
  Future<void> saveKhatmahPlan(KhatmahPlan plan) =>
      localDataSource.saveKhatmahPlan(plan);

  @override
  Future<void> deleteKhatmahPlan() => localDataSource.deleteKhatmahPlan();

  @override
  List<KhatmahHistoryEntry> getKhatmahHistory() =>
      localDataSource.getKhatmahHistory();

  @override
  Future<void> addKhatmahHistoryEntry(KhatmahHistoryEntry entry) =>
      localDataSource.addKhatmahHistoryEntry(entry);

  @override
  List<KhatmahMilestone> getKhatmahMilestones() =>
      localDataSource.getKhatmahMilestones();

  @override
  Future<void> unlockMilestone(KhatmahMilestone milestone) =>
      localDataSource.unlockMilestone(milestone);

  @override
  Future<void> saveKhatamPlanLegacy(int targetDays, DateTime startDate) =>
      quranLocalDataSource.saveProgress(targetDays, targetDays);
}
