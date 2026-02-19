part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class ToggleFavorite extends FavoritesEvent {
  final Ayah ayah;

  const ToggleFavorite(this.ayah);

  @override
  List<Object?> get props => [ayah];
}
