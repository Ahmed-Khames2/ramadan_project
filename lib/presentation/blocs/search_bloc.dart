import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

const _debounceDuration = Duration(milliseconds: 500);

EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final QuranRepository repository;

  SearchBloc({required this.repository}) : super(SearchInitial()) {
    on<SearchEvent>((event, emit) async {
      if (event is SearchQueryChanged) {
        await _onSearchQueryChanged(event, emit);
      } else if (event is ClearSearch) {
        _onClearSearch(event, emit);
      }
    }, transformer: debounce(_debounceDuration));
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    // Only search if query is at least 2 characters to reduce load
    if (query.length < 2) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    try {
      final results = await repository.search(query);
      // Check if the current state is still loading for this query
      if (emit.isDone) return;
      emit(SearchLoaded(results, query));
    } catch (e) {
      if (emit.isDone) return;
      emit(SearchError("Search failed: $e"));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
