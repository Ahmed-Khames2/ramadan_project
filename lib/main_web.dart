// Web platform-specific initialization.
// This file is imported by main.dart on the web platform.
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadan_project/features/hadith_library/data/repositories/hadith_library_web_repository.dart';
import 'package:ramadan_project/features/hadith_library/domain/repositories/hadith_library_repository.dart';

/// Creates the JSON-based in-memory Hadith Library repository for web.
Future<HadithLibraryRepository> createHadithLibraryRepository(
  SharedPreferences prefs,
) async {
  final repo = HadithLibraryWebRepository();
  // We don't eagerly call init() here — it's lazy on first access
  // to avoid blocking the app startup with loading all JSON files.
  return repo;
}
