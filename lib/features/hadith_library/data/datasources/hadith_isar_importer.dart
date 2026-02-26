import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/arabic_normalization.dart';
import '../../../../core/utils/file_path_manager.dart';
import '../models/hadith_model.dart';

class HadithIsarImporter {
  final Isar isar;
  final SharedPreferences prefs;

  static const String _importStatusKey = 'hadith_library_imported';

  HadithIsarImporter({required this.isar, required this.prefs});

  Future<void> init() async {
    final bool isImported = prefs.getBool(_importStatusKey) ?? false;
    if (!isImported) {
      // Delay start to allow the app to finish its initial frame and splash screen
      Future.delayed(const Duration(seconds: 3), () async {
        await importAllHadiths();
        await prefs.setBool(_importStatusKey, true);
        debugPrint('Hadith Library: Import completed successfully.');
      });
    }
  }

  Future<void> importAllHadiths() async {
    // Clear potentially partial data from failed previous attempts to avoid duplicates
    await isar.writeTxn(() async {
      await isar.hadithModels.clear();
      await isar.hadithChapterModels.clear();
      await isar.hadithBookModels.clear();
    });

    for (final bookKey in FilePathManager.getAllBookKeys()) {
      final int fileCount = FilePathManager.getFileCountForBook(bookKey);

      // Smaller batch size to give more control back to the UI thread
      const int batchSize = 10;

      for (int i = 1; i <= fileCount; i += batchSize) {
        final int endReached = (i + batchSize - 1) > fileCount
            ? fileCount
            : (i + batchSize - 1);

        final List<HadithModel> allHadiths = [];
        final List<HadithChapterModel> allChapters = [];
        final List<HadithBookModel> allBooks = [];

        for (int j = i; j <= endReached; j++) {
          final path = FilePathManager.getBookHadithPath(bookKey, j);
          try {
            final jsonString = await rootBundle.loadString(path);
            final result = await compute(_parseJsonAndNormalize, {
              'jsonString': jsonString,
              'bookKey': bookKey,
            });

            allHadiths.addAll(result.hadiths);
            if (result.chapter != null) allChapters.add(result.chapter!);
            if (result.book != null) allBooks.add(result.book!);
          } catch (e) {
            debugPrint('Error loading hadith file $path: $e');
          }
        }

        // Save batch to Isar
        if (allHadiths.isNotEmpty ||
            allChapters.isNotEmpty ||
            allBooks.isNotEmpty) {
          await isar.writeTxn(() async {
            if (allChapters.isNotEmpty) {
              await isar.hadithChapterModels.putAll(allChapters);
            }
            if (allBooks.isNotEmpty) {
              await isar.hadithBookModels.putAll(allBooks);
            }
            if (allHadiths.isNotEmpty) {
              await isar.hadithModels.putAll(allHadiths);
            }
          });
          debugPrint('Imported batch for $bookKey: files $i to $endReached');

          // Yield more time to the main thread (UI) for a smoother experience
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    }
  }

  static _ImportResult _parseJsonAndNormalize(Map<String, dynamic> params) {
    final String jsonString = params['jsonString'];
    final String bookKey = params['bookKey'];

    final Map<String, dynamic> data = json.decode(jsonString);
    final metadata = data['metadata'] ?? {};
    final arabicMeta = metadata['arabic'] ?? {};
    final englishMeta = metadata['english'] ?? {};
    final chapterData =
        data['chapter']; // Might be null in some files (e.g. Muslim)

    final List<dynamic> hadithList = data['hadiths'] ?? [];
    final List<HadithModel> hadithModels = [];

    final bookTitle = arabicMeta['title'] ?? '';

    // Fallback for chapter metadata if root 'chapter' is missing
    String chapterTitleAr = '';
    String chapterTitleEn = '';
    int chapterId = 0;

    if (chapterData != null) {
      chapterId = chapterData['id'] ?? 0;
      chapterTitleAr = chapterData['arabic'] ?? '';
      chapterTitleEn = chapterData['english'] ?? '';
    } else {
      // Fallback: extraction from metadata introduction
      chapterTitleAr = arabicMeta['introduction'] ?? '';
      chapterTitleEn = englishMeta['introduction'] ?? '';
      if (hadithList.isNotEmpty) {
        chapterId = hadithList[0]['chapterId'] ?? 0;
      }
    }

    for (final h in hadithList) {
      final String text = h['arabic'] ?? '';
      hadithModels.add(
        HadithModel(
          bookKey: bookKey,
          bookId: h['bookId'] ?? 0,
          chapterId: h['chapterId'] ?? (h['idInBook'] == 0 ? 0 : chapterId),
          idInBook: h['idInBook'] ?? 0,
          textArabic: text,
          normalizedText: ArabicNormalization.normalize(text),
          chapterTitle: chapterTitleAr,
          bookTitle: bookTitle,
        ),
      );
    }

    HadithChapterModel? chapter;
    if (chapterId > 0 || chapterTitleAr.isNotEmpty) {
      chapter = HadithChapterModel(
        bookKey: bookKey,
        chapterId: chapterId,
        titleArabic: chapterTitleAr,
        titleEnglish: chapterTitleEn,
      )..id = fastHash('${bookKey}_$chapterId');
    }

    HadithBookModel? book;
    if (arabicMeta.isNotEmpty) {
      book = HadithBookModel(
        key: bookKey,
        nameArabic: arabicMeta['title'] ?? '',
        nameEnglish: englishMeta['title'] ?? '',
        authorArabic: arabicMeta['author'] ?? '',
        authorEnglish: englishMeta['author'] ?? '',
      )..id = fastHash(bookKey);
    }

    return _ImportResult(hadiths: hadithModels, chapter: chapter, book: book);
  }
}

/// FNV-1a 64bit hash algorithm optimized for Dart Strings
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}

class _ImportResult {
  final List<HadithModel> hadiths;
  final HadithChapterModel? chapter;
  final HadithBookModel? book;

  _ImportResult({required this.hadiths, this.chapter, this.book});
}
