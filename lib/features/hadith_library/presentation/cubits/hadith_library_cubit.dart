import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/hadith.dart';
import '../../domain/repositories/hadith_library_repository.dart';

part 'hadith_library_state.dart';

class HadithLibraryCubit extends Cubit<HadithLibraryState> {
  final HadithLibraryRepository repository;

  HadithLibraryCubit({required this.repository})
    : super(HadithLibraryInitial());

  Future<void> loadBooks() async {
    emit(HadithLibraryLoading());
    try {
      final books = await repository.getBooks();
      emit(HadithLibraryBooksLoaded(books: books));
    } catch (e) {
      emit(HadithLibraryError(message: e.toString()));
    }
  }

  Future<void> loadChapters(String bookKey) async {
    emit(HadithLibraryLoading());
    try {
      final chapters = await repository.getChapters(bookKey);
      emit(HadithLibraryChaptersLoaded(chapters: chapters));
    } catch (e) {
      emit(HadithLibraryError(message: e.toString()));
    }
  }

  Future<void> loadHadiths({
    required String bookKey,
    required int chapterId,
    int page = 0,
    bool isLoadMore = false,
  }) async {
    final currentState = state;
    List<Hadith> oldHadiths = [];

    if (isLoadMore && currentState is HadithLibraryHadithsLoaded) {
      oldHadiths = currentState.hadiths;
      emit(
        HadithLibraryHadithsLoaded(
          hadiths: oldHadiths,
          isLoadingMore: true,
          hasReachedMax: false,
        ),
      );
    } else {
      emit(HadithLibraryLoading());
    }

    try {
      final hadiths = await repository.getHadithsByChapter(
        bookKey: bookKey,
        chapterId: chapterId,
        page: page,
      );

      final bool hasReachedMax = hadiths.length < 20;

      emit(
        HadithLibraryHadithsLoaded(
          hadiths: isLoadMore ? (oldHadiths + hadiths) : hadiths,
          hasReachedMax: hasReachedMax,
          currentPage: page,
        ),
      );
    } catch (e) {
      emit(HadithLibraryError(message: e.toString()));
    }
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      return; // Or return to previous state
    }

    emit(HadithLibraryLoading());
    try {
      final results = await repository.searchHadiths(query);
      emit(HadithLibrarySearchResults(results: results));
    } catch (e) {
      emit(HadithLibraryError(message: e.toString()));
    }
  }
}
