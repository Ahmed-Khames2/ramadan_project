import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:quran/quran.dart' as quran;
import '../../../../data/models/user_progress_model.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';

import '../../domain/entities/quran_page.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_local_datasource.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDataSource localDataSource;

  // Map<PageNumber, List<AyahReference>>
  final Map<int, List<_AyahRef>> _pageMap = {};

  // Cache for loaded Surah JSONs and Tafsir
  final Map<int, Map<String, dynamic>> _surahCache = {};
  final Map<int, Map<String, dynamic>> _tafsirCache = {};

  // Cache for Juz Start Pages: Map<JuzNumber, PageNumber>
  final Map<int, int> _juzStartPages = {};

  // Search Caches
  static final Map<int, Map<int, String>> _normalizedAyahCache = {};
  static final Map<int, String> _normalizedSurahNameCache = {};
  static bool _isSearchCacheInitialized = false;
  static Future<void>? _initializationFuture;

  QuranRepositoryImpl({required this.localDataSource});

  @override
  Future<void> init() async {
    await localDataSource.init();

    if (_pageMap.isEmpty) {
      // Build page mapping in background to prevent UI freeze
      final result = await compute(_buildPageMappings, null);
      _pageMap.addAll(result.pageMap);
      _juzStartPages.addAll(result.juzStartPages);
    }

    // Start search cache initialization in background
    _initializeSearchCache();
  }

  static _PageMappingResult _buildPageMappings(_) {
    final Map<int, List<_AyahRef>> pageMap = {};
    final Map<int, int> juzStartPages = {};

    for (int surah = 1; surah <= 114; surah++) {
      int ayahCount = quran.getVerseCount(surah);
      for (int ayah = 1; ayah <= ayahCount; ayah++) {
        int page = quran.getPageNumber(surah, ayah);
        int juz = quran.getJuzNumber(surah, ayah);

        if (!pageMap.containsKey(page)) {
          pageMap[page] = [];
        }
        pageMap[page]!.add(_AyahRef(surah, ayah));

        if (!juzStartPages.containsKey(juz)) {
          juzStartPages[juz] = page;
        }
      }
    }
    return _PageMappingResult(pageMap, juzStartPages);
  }

  @override
  int getJuzStartPage(int juzNumber) {
    return _juzStartPages[juzNumber] ?? 1;
  }

  @override
  Future<QuranPage> getPage(int pageNumber) async {
    if (!_pageMap.containsKey(pageNumber)) {
      return QuranPage(
        pageNumber: pageNumber,
        ayahs: [],
        surahName: '',
        juzNumber: 0,
      );
    }

    final refs = _pageMap[pageNumber]!;
    final List<Ayah> pageAyahs = [];

    // Pre-load required surahs
    final Set<int> surahsOnPage = refs.map((e) => e.surah).toSet();
    for (final surahNum in surahsOnPage) {
      if (!_surahCache.containsKey(surahNum)) {
        await _loadSurahJson(surahNum);
      }
    }

    for (final ref in refs) {
      final surahJson = _surahCache[ref.surah]!;
      final verses = surahJson['verse'] as Map<String, dynamic>;
      final text =
          verses['verse_${ref.ayah}'] as String? ?? 'Error loading text';

      pageAyahs.add(
        Ayah(
          surahNumber: ref.surah,
          ayahNumber: ref.ayah,
          globalAyahNumber: _getGlobalAyahNumber(ref.surah, ref.ayah),
          text: text,
          pageNumber: pageNumber,
          surahName: quran.getSurahNameArabic(ref.surah),
          isSajda: quran.isSajdahVerse(ref.surah, ref.ayah),
        ),
      );
    }

    final firstRef = refs.first;
    return QuranPage(
      pageNumber: pageNumber,
      ayahs: pageAyahs,
      surahName: quran.getSurahNameArabic(firstRef.surah),
      juzNumber: quran.getJuzNumber(firstRef.surah, firstRef.ayah),
    );
  }

  @override
  Future<List<Ayah>> getAyahsForPage(int pageNumber) async {
    final page = await getPage(pageNumber);
    return page.ayahs;
  }

  @override
  Future<List<Ayah>> getAyahsForSurah(int surahNumber) async {
    if (!_surahCache.containsKey(surahNumber)) {
      await _loadSurahJson(surahNumber);
    }

    final surahJson = _surahCache[surahNumber]!;
    final verses = surahJson['verse'] as Map<String, dynamic>;
    final int count = quran.getVerseCount(surahNumber);
    final List<Ayah> ayahs = [];

    for (int v = 1; v <= count; v++) {
      ayahs.add(
        Ayah(
          surahNumber: surahNumber,
          ayahNumber: v,
          text: verses['verse_$v'] ?? '',
          pageNumber: quran.getPageNumber(surahNumber, v),
          globalAyahNumber: _getGlobalAyahNumber(surahNumber, v),
          surahName: quran.getSurahNameArabic(surahNumber),
        ),
      );
    }
    return ayahs;
  }

  @override
  Future<String> getTafsir(int surahNumber, int ayahNumber) async {
    if (!_tafsirCache.containsKey(surahNumber)) {
      await _loadTafsirJson(surahNumber);
    }
    final surahTafsir = _tafsirCache[surahNumber];
    if (surahTafsir == null) return "Error loading Tafsir";

    return surahTafsir['verse_$ayahNumber'] ??
        surahTafsir['$ayahNumber'] ??
        "تفسير غير متاح لهذه الآية";
  }

  @override
  Future<List<Map<String, dynamic>>> search(String query) async {
    if (query.trim().isEmpty) return [];
    if (!_isSearchCacheInitialized) await _initializeSearchCache();

    return await compute(_performSearch, {
      'query': query,
      'surahNames': _normalizedSurahNameCache,
      'ayahs': _normalizedAyahCache,
    });
  }

  @override
  UserProgressModel? getProgress() => localDataSource.getProgress();

  @override
  Future<void> saveBookmark(int page) => localDataSource.addBookmark(page);

  @override
  Future<void> removeBookmark(int page) => localDataSource.removeBookmark(page);

  @override
  Future<void> saveLastRead(int page, int ayahId) =>
      localDataSource.saveProgress(page, ayahId);

  @override
  Future<void> addFavorite(int ayahId) => localDataSource.addFavorite(ayahId);

  @override
  Future<void> removeFavorite(int ayahId) =>
      localDataSource.removeFavorite(ayahId);

  @override
  Future<void> saveScrollOffset(double offset) =>
      localDataSource.saveScrollOffset(offset);

  // Helper Methods
  Future<void> _loadSurahJson(int surahNum) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/json/quranjson/surah/surah_$surahNum.json',
      );
      // Decode JSON in a separate isolate to avoid blocking the UI thread
      _surahCache[surahNum] = await compute(_parseJson, jsonString);
    } catch (e) {
      debugPrint('Error loading surah $surahNum: $e');
      _surahCache[surahNum] = {'verse': {}};
    }
  }

  Future<void> _loadTafsirJson(int surahNum) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/json/quranjson/translation/ar/ar_translation_$surahNum.json',
      );
      _tafsirCache[surahNum] = await compute(_parseJson, jsonString);
    } catch (e) {
      _tafsirCache[surahNum] = {};
    }
  }

  int _getGlobalAyahNumber(int surah, int ayah) {
    int global = 0;
    for (int i = 1; i < surah; i++) {
      global += quran.getVerseCount(i);
    }
    return global + ayah;
  }

  Future<void> _initializeSearchCache() async {
    if (_isSearchCacheInitialized) return;
    if (_initializationFuture != null) return _initializationFuture;

    _initializationFuture = compute(_buildSearchCaches, null).then((result) {
      _normalizedSurahNameCache.addAll(result.surahNames);
      _normalizedAyahCache.addAll(result.ayahs);
      _isSearchCacheInitialized = true;
    });

    return _initializationFuture;
  }

  static _SearchCacheResult _buildSearchCaches(_) {
    final Map<int, String> surahNames = {};
    final Map<int, Map<int, String>> ayahs = {};

    for (int s = 1; s <= 114; s++) {
      surahNames[s] = _normalizeArabic(quran.getSurahNameArabic(s));
      ayahs[s] = {};
      int vCount = quran.getVerseCount(s);
      for (int v = 1; v <= vCount; v++) {
        ayahs[s]![v] = _normalizeArabic(
          quran.getVerse(s, v, verseEndSymbol: false),
        );
      }
    }
    return _SearchCacheResult(surahNames, ayahs);
  }

  static String _normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u0652]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  static List<Map<String, dynamic>> _performSearch(
    Map<String, dynamic> params,
  ) {
    final String query = _normalizeArabic(params['query']);
    final Map<int, String> surahNames = params['surahNames'];
    final Map<int, Map<int, String>> ayahs = params['ayahs'];
    List<Map<String, dynamic>> results = [];

    for (int i = 1; i <= 114; i++) {
      if (surahNames[i]!.contains(query)) {
        results.add({
          'type': 'surah',
          'surahNumber': i,
          'text': quran.getSurahNameArabic(i),
          'subtitle': 'سورة رقم $i',
        });
      }
    }

    for (int s = 1; s <= 114; s++) {
      ayahs[s]!.forEach((v, text) {
        if (text.contains(query)) {
          results.add({
            'type': 'ayah',
            'surahNumber': s,
            'verseNumber': v,
            'text': quran.getVerse(s, v, verseEndSymbol: false),
            'subtitle': '${quran.getSurahNameArabic(s)} : $v',
          });
        }
      });
      if (results.length > 50) break;
    }
    return results;
  }

  static Map<String, dynamic> _parseJson(String jsonString) {
    return json.decode(jsonString) as Map<String, dynamic>;
  }
}

class _AyahRef {
  final int surah;
  final int ayah;
  const _AyahRef(this.surah, this.ayah);
}

class _SearchCacheResult {
  final Map<int, String> surahNames;
  final Map<int, Map<int, String>> ayahs;
  _SearchCacheResult(this.surahNames, this.ayahs);
}

class _PageMappingResult {
  final Map<int, List<_AyahRef>> pageMap;
  final Map<int, int> juzStartPages;
  _PageMappingResult(this.pageMap, this.juzStartPages);
}
