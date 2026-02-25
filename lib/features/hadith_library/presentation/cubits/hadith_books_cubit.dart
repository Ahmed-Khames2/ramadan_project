import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/hadith.dart';
import '../../domain/repositories/hadith_library_repository.dart';

abstract class HadithBooksState extends Equatable {
  const HadithBooksState();
  @override
  List<Object?> get props => [];
}

class HadithBooksInitial extends HadithBooksState {}

class HadithBooksLoading extends HadithBooksState {}

class HadithBooksLoaded extends HadithBooksState {
  final List<HadithBook> books;
  const HadithBooksLoaded({required this.books});
  @override
  List<Object?> get props => [books];
}

class HadithBooksError extends HadithBooksState {
  final String message;
  const HadithBooksError({required this.message});
  @override
  List<Object?> get props => [message];
}

class HadithBooksCubit extends Cubit<HadithBooksState> {
  final HadithLibraryRepository repository;

  HadithBooksCubit({required this.repository}) : super(HadithBooksInitial());

  Future<void> loadBooks() async {
    emit(HadithBooksLoading());
    try {
      final books = await repository.getBooks();
      emit(HadithBooksLoaded(books: books));
    } catch (e) {
      emit(HadithBooksError(message: e.toString()));
    }
  }
}
