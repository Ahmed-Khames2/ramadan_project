import 'package:isar/isar.dart';

part 'hadith_model.g.dart';

@collection
class HadithModel {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('chapterId')])
  final String bookKey; // 'bukhari', 'muslim', etc.

  @Index()
  final int bookId;

  final int chapterId;

  final int idInBook;

  final String textArabic;

  @Index(type: IndexType.value)
  final String normalizedText;

  final String chapterTitle;
  final String bookTitle;

  HadithModel({
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

@collection
class HadithBookModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  final String key; // 'bukhari', 'muslim', etc.

  final String nameArabic;
  final String nameEnglish;
  final String authorArabic;
  final String authorEnglish;

  HadithBookModel({
    required this.key,
    required this.nameArabic,
    required this.nameEnglish,
    required this.authorArabic,
    required this.authorEnglish,
  });
}

@collection
class HadithChapterModel {
  Id id = Isar.autoIncrement;

  @Index()
  final String bookKey;

  final int chapterId;
  final String titleArabic;
  final String titleEnglish;

  HadithChapterModel({
    required this.bookKey,
    required this.chapterId,
    required this.titleArabic,
    required this.titleEnglish,
  });
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
