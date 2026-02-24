// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:io';
import 'package:ramadan_project/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadan_project/features/quran/data/datasources/quran_local_datasource.dart';
import 'package:ramadan_project/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:ramadan_project/features/khatmah/data/datasources/khatmah_local_datasource.dart';
import 'package:ramadan_project/features/khatmah/data/repositories/khatmah_repository_impl.dart';
import 'package:ramadan_project/features/favorites/data/repositories/favorites_repository.dart';

import 'package:ramadan_project/features/ramadan_worship/data/datasources/worship_local_datasource.dart';
import 'package:ramadan_project/features/ramadan_worship/data/repositories/worship_repository_impl.dart';
import 'package:ramadan_project/features/ramadan_worship/data/models/worship_task_model.dart';
import 'package:ramadan_project/features/hadith/data/repositories/hadith_repository_impl.dart';
import 'package:ramadan_project/features/hadith/data/sources/hadith_local_data_source.dart';
import 'package:ramadan_project/features/adhkar_virtues/data/repositories/adhkar_virtue_repository_impl.dart';
import 'package:ramadan_project/features/adhkar_virtues/data/sources/adhkar_virtue_local_data_source.dart';
import 'package:ramadan_project/features/hadith_library/domain/entities/hadith.dart';
import 'package:ramadan_project/features/hadith_library/domain/repositories/hadith_library_repository.dart';

import 'package:ramadan_project/features/ramadan_worship/data/models/day_progress_model.dart';
import 'package:ramadan_project/features/ramadan_worship/data/datasources/custom_tasks_datasource.dart';

// Mock Path Provider for testing
class MockPathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getApplicationDocumentsDirectory() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<String?> getApplicationSupportDirectory() async {
    return Directory.systemTemp.path;
  }
}

void main() {
  setUpAll(() async {
    // Mock path provider
    PathProviderPlatform.instance = MockPathProviderPlatform();

    // Initialize Hive for testing
    final tempDir = Directory.systemTemp;
    Hive.init(tempDir.path);

    // Register Adapters
    if (!Hive.isAdapterRegistered(5))
      Hive.registerAdapter(WorshipTaskModelAdapter());
    if (!Hive.isAdapterRegistered(6))
      Hive.registerAdapter(DayProgressModelAdapter());
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize DataSources
    final quranDataSource = QuranLocalDataSource();
    await quranDataSource.init();

    final khatmahDataSource = KhatmahLocalDataSource();
    await khatmahDataSource.init();

    // Initialize Repositories
    final quranRepository = QuranRepositoryImpl(
      localDataSource: quranDataSource,
    );
    await quranRepository.init();

    final khatmahRepository = KhatmahRepositoryImpl(
      localDataSource: khatmahDataSource,
      quranLocalDataSource: quranDataSource,
    );

    final favoritesRepository = FavoritesRepository();
    await favoritesRepository.init();

    final worshipDataSource = WorshipLocalDataSourceImpl();
    await worshipDataSource.init();

    final customTasksDataSource = CustomTasksDataSourceImpl();
    await customTasksDataSource.init();

    final worshipRepository = WorshipRepositoryImpl(
      localDataSource: worshipDataSource,
      customTasksDataSource: customTasksDataSource,
    );

    final hadithRepository = HadithRepositoryImpl(
      localDataSource: HadithLocalDataSourceImpl(),
    );

    final adhkarVirtueRepository = AdhkarVirtueRepositoryImpl(
      localDataSource: AdhkarVirtueLocalDataSourceImpl(),
    );

    final hadithLibraryRepository = _MockHadithLibraryRepository();

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MyApp(
        quranRepository: quranRepository,
        khatmahRepository: khatmahRepository,
        favoritesRepository: favoritesRepository,
        worshipRepository: worshipRepository,
        hadithRepository: hadithRepository,
        adhkarVirtueRepository: adhkarVirtueRepository,
        hadithLibraryRepository: hadithLibraryRepository,
        prefs: prefs,
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

class _MockHadithLibraryRepository implements HadithLibraryRepository {
  @override
  Future<List<HadithBook>> getBooks() async => [];
  @override
  Future<List<HadithChapter>> getChapters(String bookKey) async => [];
  @override
  Future<List<Hadith>> getHadithsByChapter({
    required String bookKey,
    required int chapterId,
    int page = 0,
    int pageSize = 20,
  }) async => [];
  @override
  Future<List<Hadith>> searchHadiths(String query, {int limit = 50}) async =>
      [];
  @override
  Future<Hadith?> getHadithById(int id) async => null;
}
