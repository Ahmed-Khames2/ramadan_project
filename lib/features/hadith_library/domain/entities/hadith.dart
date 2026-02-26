class Hadith {
  final int id;
  final String bookKey;
  final int bookId;
  final int chapterId;
  final int idInBook;
  final String textArabic;
  final String chapterTitle;
  final String bookTitle;

  Hadith({
    required this.id,
    required this.bookKey,
    required this.bookId,
    required this.chapterId,
    required this.idInBook,
    required this.textArabic,
    required this.chapterTitle,
    required this.bookTitle,
  });
}

class HadithBook {
  final String key;
  final String nameArabic;
  final String nameEnglish;
  final String authorArabic;
  final String authorEnglish;

  HadithBook({
    required this.key,
    required this.nameArabic,
    required this.nameEnglish,
    required this.authorArabic,
    required this.authorEnglish,
  });
}

class HadithChapter {
  final String bookKey;
  final int chapterId;
  final String titleArabic;
  final String titleEnglish;

  HadithChapter({
    required this.bookKey,
    required this.chapterId,
    required this.titleArabic,
    required this.titleEnglish,
  });
}
