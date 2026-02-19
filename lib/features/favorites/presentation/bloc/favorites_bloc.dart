import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ramadan_project/features/favorites/data/repositories/favorites_repository.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';
import 'package:ramadan_project/features/favorites/domain/entities/favorite_ayah.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository repository;

  FavoritesBloc({required this.repository}) : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final favorites = await repository.getAllFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError("Failed to load favorites: $e"));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final isFav = await repository.isFavorite(event.ayah.globalAyahNumber);

      if (isFav) {
        await repository.removeFavorite(event.ayah.globalAyahNumber);
      } else {
        await repository.addFavorite(
          FavoriteAyah(
            surahNumber: event.ayah.surahNumber,
            ayahNumber: event.ayah.ayahNumber,
            globalAyahNumber: event.ayah.globalAyahNumber,
            text: event.ayah.text,
            surahName: event.ayah.surahName,
            addedAt: DateTime.now(),
          ),
        );
      }

      add(LoadFavorites());
    } catch (e) {
      emit(FavoritesError("Failed to update favorite: $e"));
    }
  }
}
