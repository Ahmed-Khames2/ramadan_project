import '../../domain/entities/hadith.dart';
import '../../domain/repositories/hadith_repository.dart';
import '../sources/hadith_local_data_source.dart';

class HadithRepositoryImpl implements HadithRepository {
  final HadithLocalDataSource localDataSource;

  HadithRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Hadith>> getHadiths() async {
    return await localDataSource.getHadiths();
  }
}
