import '../../../../data/models/user_progress_model.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';
import '../entities/quran_page.dart';

abstract class QuranRepository {
  /// Initialize the repository
  Future<void> init();

  /// Get the data for a specific Mushaf Page (1-604)
  /// Get the data for a specific Mushaf Page (1-604)
  Future<QuranPage> getPage(int pageNumber);

  /// Get simplified page data (metadata only) synchronously for instant loading
  QuranPage? getPagePlaceholder(int pageNumber);

  /// Get Ayahs for a specific page (legacy support)
  Future<List<Ayah>> getAyahsForPage(int pageNumber);

  /// Get Ayahs for a specific surah
  Future<List<Ayah>> getAyahsForSurah(int surahNumber);

  /// Get the starting page number for a given Juz (1-30)
  int getJuzStartPage(int juzNumber);

  /// Get Tafsir for a specific ayah
  Future<String> getTafsir(int surahNumber, int ayahNumber);

  /// Search across all ayahs
  Future<List<Map<String, dynamic>>> search(String query);

  /// Get user progress
  UserProgressModel? getProgress();

  /// Persistence
  Future<void> saveBookmark(int page);
  Future<void> removeBookmark(int page);
  Future<void> saveLastRead(int page, int ayahId);
  Future<void> addFavorite(int ayahId);
  Future<void> removeFavorite(int ayahId);
  Future<void> saveScrollOffset(double offset);
}
