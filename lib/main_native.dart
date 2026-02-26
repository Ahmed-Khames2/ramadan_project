// Native (Android/iOS/Desktop) platform-specific initialization.
// This file is imported by main.dart on non-web platforms.
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadan_project/features/hadith_library/data/models/hadith_model.dart';
import 'package:ramadan_project/features/hadith_library/data/datasources/hadith_isar_importer.dart';
import 'package:ramadan_project/features/hadith_library/data/repositories/hadith_library_repository_impl.dart';
import 'package:ramadan_project/features/hadith_library/domain/repositories/hadith_library_repository.dart';

/// Creates the Isar-backed Hadith Library repository for native platforms.
Future<HadithLibraryRepository> createHadithLibraryRepository(
  SharedPreferences prefs,
) async {
  final dir = await getApplicationSupportDirectory();
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  final isar = await Isar.open([
    HadithModelSchema,
    HadithBookModelSchema,
    HadithChapterModelSchema,
  ], directory: dir.path);

  // Background import (non-blocking)
  final hadithImporter = HadithIsarImporter(isar: isar, prefs: prefs);
  hadithImporter.init();

  return HadithLibraryRepositoryImpl(isar: isar);
}
