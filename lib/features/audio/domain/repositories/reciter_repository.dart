import 'package:ramadan_project/features/audio/domain/entities/reciter.dart';

abstract class ReciterRepository {
  Future<void> saveReciter(Reciter reciter);
  Future<Reciter> getSavedReciter();
}
