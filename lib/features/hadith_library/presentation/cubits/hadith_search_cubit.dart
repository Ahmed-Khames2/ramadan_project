import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/hadith.dart';
import '../../domain/repositories/hadith_library_repository.dart';

abstract class HadithSearchState extends Equatable {
  const HadithSearchState();
  @override
  List<Object?> get props => [];
}

class HadithSearchInitial extends HadithSearchState {}

class HadithSearchLoading extends HadithSearchState {}

class HadithSearchLoaded extends HadithSearchState {
  final List<Hadith> results;
  const HadithSearchLoaded({required this.results});
  @override
  List<Object?> get props => [results];
}

class HadithSearchError extends HadithSearchState {
  final String message;
  const HadithSearchError({required this.message});
  @override
  List<Object?> get props => [message];
}

class HadithSearchCubit extends Cubit<HadithSearchState> {
  final HadithLibraryRepository repository;
  Timer? _searchTimer;

  HadithSearchCubit({required this.repository}) : super(HadithSearchInitial());

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }

  Future<void> search(String query) async {
    _searchTimer?.cancel();

    if (query.isEmpty) {
      emit(HadithSearchInitial());
      return;
    }

    emit(HadithSearchLoading());

    _searchTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await repository.searchHadiths(query);
        emit(HadithSearchLoaded(results: results));
      } catch (e) {
        emit(HadithSearchError(message: e.toString()));
      }
    });
  }
}
