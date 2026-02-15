import 'package:hive_flutter/hive_flutter.dart';
import 'package:ramadan_project/data/models/user_progress_model.dart';

class QuranLocalDataSource {
  static const String _progressBoxName = 'user_progress';

  Box<UserProgressModel>? _progressBox;

  Future<void> init() async {
    _progressBox = await Hive.openBox<UserProgressModel>(_progressBoxName);
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

  Future<void> saveSurahNumber(int surahNumber) async {
    final current = getProgress() ?? UserProgressModel();
    current.lastReadSurahNumber = surahNumber;
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
}
