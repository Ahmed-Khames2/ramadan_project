import 'package:hive_flutter/hive_flutter.dart';
import 'package:ramadan_project/features/khatmah/domain/entities/khatmah_entities.dart';
import '../models/user_progress_model.dart';

class QuranLocalDataSource {
  static const String _progressBoxName = 'user_progress';
  static const String _khatmahPlanBoxName = 'khatmah_plan';
  static const String _khatmahHistoryBoxName = 'khatmah_history';
  static const String _milestonesBoxName = 'khatmah_milestones';

  Box<UserProgressModel>? _progressBox;
  Box<KhatmahPlan>? _khatmahPlanBox;
  Box<KhatmahHistoryEntry>? _khatmahHistoryBox;
  Box<KhatmahMilestone>? _milestonesBox;

  Future<void> init() async {
    _progressBox = await Hive.openBox<UserProgressModel>(_progressBoxName);
    _khatmahPlanBox = await Hive.openBox<KhatmahPlan>(_khatmahPlanBoxName);
    _khatmahHistoryBox = await Hive.openBox<KhatmahHistoryEntry>(
      _khatmahHistoryBoxName,
    );
    _milestonesBox = await Hive.openBox<KhatmahMilestone>(_milestonesBoxName);
  }

  UserProgressModel? getProgress() {
    return _progressBox?.get('current');
  }

  Future<void> saveProgress(int page, int ayahId) async {
    final current = getProgress() ?? UserProgressModel();
    current.lastReadPage = page;
    current.lastReadAyahId = ayahId;
    await _progressBox?.put('current', current);
  }

  Future<void> saveKhatamPlan(int targetDays, DateTime startDate) async {
    final current = getProgress() ?? UserProgressModel();
    current.targetDays = targetDays;
    current.startDate = startDate;
    await _progressBox?.put('current', current);
  }

  Future<void> addBookmark(int page) async {
    final current = getProgress() ?? UserProgressModel();
    final bookmarks = current.bookmarks ?? [];
    if (!bookmarks.contains(page)) {
      current.bookmarks = [...bookmarks, page];
      await _progressBox?.put('current', current);
    }
  }

  Future<void> removeBookmark(int page) async {
    final current = getProgress() ?? UserProgressModel();
    final bookmarks = current.bookmarks ?? [];
    current.bookmarks = bookmarks.where((p) => p != page).toList();
    await _progressBox?.put('current', current);
  }

  Future<void> addFavorite(int ayahId) async {
    final current = getProgress() ?? UserProgressModel();
    final favorites = current.favorites ?? [];
    if (!favorites.contains(ayahId)) {
      current.favorites = [...favorites, ayahId];
      await _progressBox?.put('current', current);
    }
  }

  Future<void> removeFavorite(int ayahId) async {
    final current = getProgress() ?? UserProgressModel();
    final favorites = current.favorites ?? [];
    current.favorites = favorites.where((id) => id != ayahId).toList();
    await _progressBox?.put('current', current);
  }

  Future<void> saveScrollOffset(double offset) async {
    final current = getProgress() ?? UserProgressModel();
    current.scrollOffset = offset;
    await _progressBox?.put('current', current);
  }

  Future<void> saveSurahNumber(int surahNumber) async {
    final current = getProgress() ?? UserProgressModel();
    current.lastReadSurahNumber = surahNumber;
    await _progressBox?.put('current', current);
  }

  // Khatmah Methods
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
