// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:io';
import 'package:ramadan_project/main.dart';
import 'package:ramadan_project/features/quran/data/datasources/quran_local_datasource.dart';
import 'package:ramadan_project/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:ramadan_project/features/khatmah/data/datasources/khatmah_local_datasource.dart';
import 'package:ramadan_project/features/khatmah/data/repositories/khatmah_repository_impl.dart';
import 'package:ramadan_project/features/favorites/data/repositories/favorites_repository.dart';

// Mock Path Provider for testing
class MockPathProviderPlatform extends PathProviderPlatform with MockPlatformInterfaceMixin {
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
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize DataSources
    final quranDataSource = QuranLocalDataSource();
    await quranDataSource.init();

    final khatmahDataSource = KhatmahLocalDataSource();
    await khatmahDataSource.init();

    // Initialize Repositories
    final quranRepository = QuranRepositoryImpl(localDataSource: quranDataSource);
    await quranRepository.init();

    final khatmahRepository = KhatmahRepositoryImpl(
      localDataSource: khatmahDataSource,
      quranLocalDataSource: quranDataSource,
    );

    final favoritesRepository = FavoritesRepository();
    await favoritesRepository.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      quranRepository: quranRepository,
      khatmahRepository: khatmahRepository,
      favoritesRepository: favoritesRepository,
    ));

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
