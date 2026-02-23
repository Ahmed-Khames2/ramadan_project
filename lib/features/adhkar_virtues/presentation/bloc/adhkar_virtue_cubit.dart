import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/adhkar_virtue.dart';
import '../../domain/repositories/adhkar_virtue_repository.dart';

// States
abstract class AdhkarVirtueState extends Equatable {
  const AdhkarVirtueState();
  @override
  List<Object?> get props => [];
}

class AdhkarVirtueInitial extends AdhkarVirtueState {}

class AdhkarVirtueLoading extends AdhkarVirtueState {}

class AdhkarVirtueLoaded extends AdhkarVirtueState {
  final List<AdhkarVirtue> adhkar;
  final List<AdhkarVirtue> filteredAdhkar;
  final int activeCategory; // 0: All, 1: Morning, 2: Evening

  const AdhkarVirtueLoaded({
    required this.adhkar,
    required this.filteredAdhkar,
    this.activeCategory = 0,
  });

  @override
  List<Object?> get props => [adhkar, filteredAdhkar, activeCategory];
}

class AdhkarVirtueError extends AdhkarVirtueState {
  final String message;
  const AdhkarVirtueError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class AdhkarVirtueCubit extends Cubit<AdhkarVirtueState> {
  final AdhkarVirtueRepository repository;
  List<AdhkarVirtue> _allAdhkar = [];

  AdhkarVirtueCubit({required this.repository}) : super(AdhkarVirtueInitial());

  Future<void> loadAdhkar() async {
    emit(AdhkarVirtueLoading());
    try {
      _allAdhkar = await repository.getAdhkarVirtues();
      emit(AdhkarVirtueLoaded(adhkar: _allAdhkar, filteredAdhkar: _allAdhkar));
    } catch (e) {
      emit(AdhkarVirtueError('فشل تحميل الأذكار: $e'));
    }
  }

  void filterByCategory(int categoryIndex) {
    if (state is AdhkarVirtueLoaded) {
      List<AdhkarVirtue> filtered;

      if (categoryIndex == 0) {
        filtered = _allAdhkar;
      } else {
        filtered = _allAdhkar.where((a) => a.type == categoryIndex).toList();
      }

      emit(
        AdhkarVirtueLoaded(
          adhkar: _allAdhkar,
          filteredAdhkar: filtered,
          activeCategory: categoryIndex,
        ),
      );
    }
  }

  void searchAdhkar(String query) {
    if (state is AdhkarVirtueLoaded) {
      final currentState = state as AdhkarVirtueLoaded;
      final filtered = _allAdhkar.where((a) {
        final matchesQuery =
            a.content.contains(query) || a.fadl.contains(query);
        final matchesCategory =
            currentState.activeCategory == 0 ||
            a.type == currentState.activeCategory;
        return matchesQuery && matchesCategory;
      }).toList();

      emit(
        AdhkarVirtueLoaded(
          adhkar: _allAdhkar,
          filteredAdhkar: filtered,
          activeCategory: currentState.activeCategory,
        ),
      );
    }
  }
}
