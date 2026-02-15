part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class ToggleFavorite extends FavoritesEvent {
  final int ayahId;

  const ToggleFavorite(this.ayahId);

  @override
  List<Object?> get props => [ayahId];
}
