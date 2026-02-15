import 'package:hive/hive.dart';
import 'package:ramadan_project/features/favorites/domain/entities/favorite_ayah.dart';

class FavoritesRepository {
  static const String _boxName = 'favorites';
  Box<FavoriteAyah>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<FavoriteAyah>(_boxName);
  }

  Future<void> addFavorite(FavoriteAyah favorite) async {
    await _ensureInitialized();
    await _box!.put(favorite.globalAyahNumber, favorite);
  }

  Future<void> removeFavorite(int globalAyahNumber) async {
    await _ensureInitialized();
    await _box!.delete(globalAyahNumber);
  }

  Future<bool> isFavorite(int globalAyahNumber) async {
    await _ensureInitialized();
    return _box!.containsKey(globalAyahNumber);
  }

  Future<List<FavoriteAyah>> getAllFavorites() async {
    await _ensureInitialized();
    return _box!.values.toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  Future<void> clearAll() async {
    await _ensureInitialized();
    await _box!.clear();
  }

  Future<void> _ensureInitialized() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
  }

  Future<void> close() async {
    await _box?.close();
  }
}
