import '../entities/adhkar_virtue.dart';

abstract class AdhkarVirtueRepository {
  Future<List<AdhkarVirtue>> getAdhkarVirtues();
}
