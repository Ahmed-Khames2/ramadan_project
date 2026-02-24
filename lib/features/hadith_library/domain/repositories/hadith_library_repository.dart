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
  Future<Hadith?> getHadithById(int id);
}
