import 'package:isar/isar.dart';
import '../../../../core/utils/arabic_normalization.dart';
import '../../domain/entities/hadith.dart';
import '../../domain/repositories/hadith_library_repository.dart';
import '../models/hadith_model.dart';

class HadithLibraryRepositoryImpl implements HadithLibraryRepository {
  final Isar isar;

  HadithLibraryRepositoryImpl({required this.isar});

  @override
  Future<List<HadithBook>> getBooks() async {
    final models = await isar.hadithBookModels.where().findAll();
    return models
        .map(
          (m) => HadithBook(
            key: m.key,
            nameArabic: m.nameArabic,
            nameEnglish: m.nameEnglish,
            authorArabic: m.authorArabic,
            authorEnglish: m.authorEnglish,
          ),
        )
        .toList();
  }

  @override
  Future<List<HadithChapter>> getChapters(String bookKey) async {
    final models = await isar.hadithChapterModels
        .where()
        .bookKeyEqualTo(bookKey)
        .sortByChapterId()
        .findAll();
    return models
        .map(
          (m) => HadithChapter(
            bookKey: m.bookKey,
            chapterId: m.chapterId,
            titleArabic: m.titleArabic,
            titleEnglish: m.titleEnglish,
          ),
        )
        .toList();
  }

  @override
  Future<List<Hadith>> getHadithsByChapter({
    required String bookKey,
    required int chapterId,
    int page = 0,
    int pageSize = 20,
  }) async {
    final models = await isar.hadithModels
        .where()
        .bookKeyChapterIdEqualTo(bookKey, chapterId)
        .offset(page * pageSize)
        .limit(pageSize)
        .findAll();

    return models.map((m) => _mapToEntity(m)).toList();
  }

  @override
  Future<List<Hadith>> searchHadiths(String query, {int limit = 50}) async {
    final normalizedQuery = ArabicNormalization.normalize(query);
    if (normalizedQuery.isEmpty) return [];

    final models = await isar.hadithModels
        .filter()
        .normalizedTextContains(normalizedQuery)
        .limit(limit)
        .findAll();

    return models.map((m) => _mapToEntity(m)).toList();
  }

  @override
  Future<Hadith?> getHadithById(int id) async {
    final model = await isar.hadithModels.get(id);
    return model != null ? _mapToEntity(model) : null;
  }

  Hadith _mapToEntity(HadithModel m) {
    return Hadith(
      id: m.id,
      bookKey: m.bookKey,
      bookId: m.bookId,
      chapterId: m.chapterId,
      idInBook: m.idInBook,
      textArabic: m.textArabic,
      chapterTitle: m.chapterTitle,
      bookTitle: m.bookTitle,
    );
  }
}
