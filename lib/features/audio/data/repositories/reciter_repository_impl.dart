import 'package:ramadan_project/features/audio/domain/entities/reciter.dart';
import 'package:ramadan_project/features/audio/domain/repositories/reciter_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadan_project/core/constants/reciters.dart';

class ReciterRepositoryImpl implements ReciterRepository {
  static const String _key = 'selected_reciter_id';

  @override
  Future<void> saveReciter(Reciter reciter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, reciter.id);
  }

  @override
  Future<Reciter> getSavedReciter() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_key);

    if (id == null) {
      return Reciters.defaultReciter;
    }

    return Reciters.all.firstWhere(
      (r) => r.id == id,
      orElse: () => Reciters.defaultReciter,
    );
  }
}
