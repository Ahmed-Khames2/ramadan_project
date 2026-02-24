import '../../domain/entities/adhkar_virtue.dart';
import '../../domain/repositories/adhkar_virtue_repository.dart';
import '../sources/adhkar_virtue_local_data_source.dart';

class AdhkarVirtueRepositoryImpl implements AdhkarVirtueRepository {
  final AdhkarVirtueLocalDataSource localDataSource;

  AdhkarVirtueRepositoryImpl({required this.localDataSource});

  @override
  Future<List<AdhkarVirtue>> getAdhkarVirtues() async {
    return await localDataSource.getAdhkarVirtues();
  }
}
