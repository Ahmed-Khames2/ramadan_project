import '../entities/hadith.dart';

abstract class HadithRepository {
  Future<List<Hadith>> getHadiths();
}
