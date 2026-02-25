import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/utils/arabic_normalization.dart';
import '../../../../core/utils/file_path_manager.dart';
import '../../domain/entities/hadith.dart';
import '../../domain/repositories/hadith_library_repository.dart';

/// Web-compatible implementation of [HadithLibraryRepository].
/// Since Isar does not support Flutter Web, this class loads data directly
/// from JSON asset files and stores it in-memory for the session.
class HadithLibraryWebRepository implements HadithLibraryRepository {
  // In-memory caches
  final List<HadithBook> _books = [];
  final List<HadithChapter> _chapters = [];
  final List<_HadithRecord> _hadiths = [];

  bool _initialized = false;
  int _hadithAutoId = 1;

  /// Must be called before using this repository.
  Future<void> init() async {
    if (_initialized) return;
    await _loadAllData();
    _initialized = true;
  }

  Future<void> _loadAllData() async {
    final Set<String> seenBookKeys = {};
    final Map<String, Set<int>> seenChapterIds = {};

    for (final bookKey in FilePathManager.getAllBookKeys()) {
      final fileCount = FilePathManager.getFileCountForBook(bookKey);

      for (int i = 1; i <= fileCount; i++) {
        final path = FilePathManager.getBookHadithPath(bookKey, i);
        try {
          final jsonString = await rootBundle.loadString(path);
          final Map<String, dynamic> data = json.decode(jsonString);

          final metadata = data['metadata'] ?? {};
          final arabicMeta = metadata['arabic'] ?? {};
          final englishMeta = metadata['english'] ?? {};
          final chapterData = data['chapter'];
          final List<dynamic> hadithList = data['hadiths'] ?? [];

          final bookTitle = arabicMeta['title'] ?? '';
          String chapterTitleAr = '';
          String chapterTitleEn = '';
          int chapterId = 0;

          if (chapterData != null) {
            chapterId = chapterData['id'] ?? 0;
            chapterTitleAr = chapterData['arabic'] ?? '';
            chapterTitleEn = chapterData['english'] ?? '';
          } else {
            chapterTitleAr = arabicMeta['introduction'] ?? '';
            chapterTitleEn = englishMeta['introduction'] ?? '';
            if (hadithList.isNotEmpty) {
              chapterId = hadithList[0]['chapterId'] ?? 0;
            }
          }

          // Store book (deduped by key)
          if (!seenBookKeys.contains(bookKey) && arabicMeta.isNotEmpty) {
            seenBookKeys.add(bookKey);
            _books.add(
              HadithBook(
                key: bookKey,
                nameArabic: arabicMeta['title'] ?? '',
                nameEnglish: englishMeta['title'] ?? '',
                authorArabic: arabicMeta['author'] ?? '',
                authorEnglish: englishMeta['author'] ?? '',
              ),
            );
          }

          // Store chapter (deduped by bookKey+chapterId)
          seenChapterIds[bookKey] ??= {};
          if (chapterId > 0 && !seenChapterIds[bookKey]!.contains(chapterId)) {
            seenChapterIds[bookKey]!.add(chapterId);
            _chapters.add(
              HadithChapter(
                bookKey: bookKey,
                chapterId: chapterId,
                titleArabic: chapterTitleAr,
                titleEnglish: chapterTitleEn,
              ),
            );
          }

          // Store hadiths
          for (final h in hadithList) {
            final String text = h['arabic'] ?? '';
            _hadiths.add(
              _HadithRecord(
                id: _hadithAutoId++,
                bookKey: bookKey,
                bookId: h['bookId'] ?? 0,
                chapterId: h['chapterId'] ?? chapterId,
                idInBook: h['idInBook'] ?? 0,
                textArabic: text,
                normalizedText: ArabicNormalization.normalize(text),
                chapterTitle: chapterTitleAr,
                bookTitle: bookTitle,
              ),
            );
          }
        } catch (e) {
          // Skip files that fail to load (non-fatal)
        }
      }
    }
  }

  @override
  Future<List<HadithBook>> getBooks() async {
    await init();
    return List.unmodifiable(_books);
  }

  @override
  Future<List<HadithChapter>> getChapters(String bookKey) async {
    await init();
    return _chapters.where((c) => c.bookKey == bookKey).toList()
      ..sort((a, b) => a.chapterId.compareTo(b.chapterId));
  }

  @override
  Future<List<Hadith>> getHadithsByChapter({
    required String bookKey,
    required int chapterId,
    int page = 0,
    int pageSize = 20,
  }) async {
    await init();
    final filtered = _hadiths
        .where((h) => h.bookKey == bookKey && h.chapterId == chapterId)
        .skip(page * pageSize)
        .take(pageSize)
        .map(_toEntity)
        .toList();
    return filtered;
  }

  @override
  Future<List<Hadith>> searchHadiths(String query, {int limit = 50}) async {
    await init();
    if (query.isEmpty) return [];
    final normalized = ArabicNormalization.normalize(query);
    return _hadiths
        .where((h) => h.normalizedText.contains(normalized))
        .take(limit)
        .map(_toEntity)
        .toList();
  }

  @override
  Future<List<Hadith>> searchHadithsInChapter({
    required String query,
    required String bookKey,
    required int chapterId,
  }) async {
    await init();
    if (query.isEmpty) return [];
    final normalized = ArabicNormalization.normalize(query);
    return _hadiths
        .where(
          (h) =>
              h.bookKey == bookKey &&
              h.chapterId == chapterId &&
              h.normalizedText.contains(normalized),
        )
        .map(_toEntity)
        .toList();
  }

  @override
  Future<int> getHadithCountByChapter({
    required String bookKey,
    required int chapterId,
  }) async {
    await init();
    return _hadiths
        .where((h) => h.bookKey == bookKey && h.chapterId == chapterId)
        .length;
  }

  @override
  Future<Hadith?> getHadithById(int id) async {
    await init();
    try {
      return _toEntity(_hadiths.firstWhere((h) => h.id == id));
    } catch (_) {
      return null;
    }
  }

  Hadith _toEntity(_HadithRecord r) => Hadith(
    id: r.id,
    bookKey: r.bookKey,
    bookId: r.bookId,
    chapterId: r.chapterId,
    idInBook: r.idInBook,
    textArabic: r.textArabic,
    chapterTitle: r.chapterTitle,
    bookTitle: r.bookTitle,
  );
}

class _HadithRecord {
  final int id;
  final String bookKey;
  final int bookId;
  final int chapterId;
  final int idInBook;
  final String textArabic;
  final String normalizedText;
  final String chapterTitle;
  final String bookTitle;

  const _HadithRecord({
    required this.id,
    required this.bookKey,
    required this.bookId,
    required this.chapterId,
    required this.idInBook,
    required this.textArabic,
    required this.normalizedText,
    required this.chapterTitle,
    required this.bookTitle,
  });
}
