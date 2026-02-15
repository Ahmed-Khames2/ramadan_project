import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final QuranRepository repository;

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
      final progress = repository.getProgress();
      emit(FavoritesLoaded(progress?.favorites ?? []));
    } catch (e) {
      emit(FavoritesError("Failed to load favorites: $e"));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final progress = repository.getProgress();
      final favorites = progress?.favorites ?? [];

      if (favorites.contains(event.ayahId)) {
        await repository.removeFavorite(event.ayahId);
      } else {
        await repository.addFavorite(event.ayahId);
      }

      add(LoadFavorites());
    } catch (e) {
      emit(FavoritesError("Failed to update favorite: $e"));
    }
  }
}
