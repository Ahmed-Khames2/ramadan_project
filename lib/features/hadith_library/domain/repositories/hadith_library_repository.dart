import '../entities/hadith.dart';

abstract class HadithLibraryRepository {
  Future<List<HadithBook>> getBooks();
  Future<List<HadithChapter>> getChapters(String bookKey);
  Future<List<Hadith>> getHadithsByChapter({
    required String bookKey,
    required int chapterId,
    int page = 0,
    int pageSize = 20,
  });
  Future<List<Hadith>> searchHadiths(String query, {int limit = 50});
  Future<List<Hadith>> searchHadithsInChapter({
    required String query,
    required String bookKey,
    required int chapterId,
  });
  Future<int> getHadithCountByChapter({
    required String bookKey,
    required int chapterId,
  });
  Future<Hadith?> getHadithById(int id);
}
