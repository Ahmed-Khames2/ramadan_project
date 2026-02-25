import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/hadith.dart';
import '../../domain/repositories/hadith_library_repository.dart';

abstract class HadithListState extends Equatable {
  const HadithListState();
  @override
  List<Object?> get props => [];
}

class HadithListInitial extends HadithListState {}

class HadithListLoading extends HadithListState {}

class HadithListLoaded extends HadithListState {
  final List<Hadith> hadiths;
  final bool hasReachedMax;
  final int currentPage;
  final bool isLoadingMore;
  final int totalCount;
  final String searchQuery;
  final Set<int> readHadithIds;
  final bool isSearching;

  const HadithListLoaded({
    required this.hadiths,
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.isLoadingMore = false,
    this.totalCount = 0,
    this.searchQuery = '',
    this.readHadithIds = const {},
    this.isSearching = false,
  });

  @override
  List<Object?> get props => [
    hadiths,
    hasReachedMax,
    currentPage,
    isLoadingMore,
    totalCount,
    searchQuery,
    readHadithIds,
    isSearching,
  ];

  HadithListLoaded copyWith({
    List<Hadith>? hadiths,
    bool? hasReachedMax,
    int? currentPage,
    bool? isLoadingMore,
    int? totalCount,
    String? searchQuery,
    Set<int>? readHadithIds,
    bool? isSearching,
  }) {
    return HadithListLoaded(
      hadiths: hadiths ?? this.hadiths,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      totalCount: totalCount ?? this.totalCount,
      searchQuery: searchQuery ?? this.searchQuery,
      readHadithIds: readHadithIds ?? this.readHadithIds,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class HadithListError extends HadithListState {
  final String message;
  const HadithListError({required this.message});
  @override
  List<Object?> get props => [message];
}

class HadithListCubit extends Cubit<HadithListState> {
  final HadithLibraryRepository repository;
  final SharedPreferences prefs;
  static const String _readKey = 'read_hadith_ids';

  HadithListCubit({required this.repository, required this.prefs})
    : super(HadithListInitial());

  Set<int> _loadReadIds() {
    final List<String>? ids = prefs.getStringList(_readKey);
    if (ids == null) return {};
    return ids.map((id) => int.parse(id)).toSet();
  }

  Future<void> loadHadiths({
    required String bookKey,
    required int chapterId,
    int page = 0,
    bool isLoadMore = false,
  }) async {
    final currentState = state;
    List<Hadith> oldHadiths = [];
    int totalCount = 0;
    Set<int> readHadithIds = _loadReadIds();

    if (isLoadMore && currentState is HadithListLoaded) {
      oldHadiths = currentState.hadiths;
      totalCount = currentState.totalCount;
      emit(currentState.copyWith(isLoadingMore: true, isSearching: false));
    } else {
      emit(HadithListLoading());
      totalCount = await repository.getHadithCountByChapter(
        bookKey: bookKey,
        chapterId: chapterId,
      );
    }

    try {
      final hadiths = await repository.getHadithsByChapter(
        bookKey: bookKey,
        chapterId: chapterId,
        page: page,
      );

      final bool hasReachedMax = hadiths.length < 20;

      emit(
        HadithListLoaded(
          hadiths: isLoadMore ? (oldHadiths + hadiths) : hadiths,
          hasReachedMax: hasReachedMax,
          currentPage: page,
          isLoadingMore: false,
          totalCount: totalCount,
          readHadithIds: readHadithIds,
          isSearching: false,
        ),
      );
    } catch (e) {
      emit(HadithListError(message: e.toString()));
    }
  }

  Future<void> searchInChapter({
    required String query,
    required String bookKey,
    required int chapterId,
  }) async {
    if (query.length < 2) {
      loadHadiths(bookKey: bookKey, chapterId: chapterId);
      return;
    }

    final currentState = state;
    if (currentState is HadithListLoaded) {
      emit(currentState.copyWith(isSearching: true, searchQuery: query));
    }

    try {
      final results = await repository.searchHadithsInChapter(
        query: query,
        bookKey: bookKey,
        chapterId: chapterId,
      );

      final readHadithIds = _loadReadIds();
      final totalCount = await repository.getHadithCountByChapter(
        bookKey: bookKey,
        chapterId: chapterId,
      );

      emit(
        HadithListLoaded(
          hadiths: results,
          hasReachedMax:
              true, // Search results are not paginated for simplicity
          currentPage: 0,
          isLoadingMore: false,
          totalCount: totalCount,
          searchQuery: query,
          readHadithIds: readHadithIds,
          isSearching: false,
        ),
      );
    } catch (e) {
      emit(HadithListError(message: e.toString()));
    }
  }

  Future<void> toggleReadStatus(int hadithId) async {
    final currentState = state;
    if (currentState is HadithListLoaded) {
      final newReadIds = Set<int>.from(currentState.readHadithIds);
      if (newReadIds.contains(hadithId)) {
        newReadIds.remove(hadithId);
      } else {
        newReadIds.add(hadithId);
      }

      await prefs.setStringList(
        _readKey,
        newReadIds.map((id) => id.toString()).toList(),
      );

      emit(currentState.copyWith(readHadithIds: newReadIds));
    }
  }
}
