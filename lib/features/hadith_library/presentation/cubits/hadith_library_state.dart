part of 'hadith_library_cubit.dart';

abstract class HadithLibraryState extends Equatable {
  const HadithLibraryState();

  @override
  List<Object?> get props => [];
}

class HadithLibraryInitial extends HadithLibraryState {}

class HadithLibraryLoading extends HadithLibraryState {}

class HadithLibraryError extends HadithLibraryState {
  final String message;
  const HadithLibraryError({required this.message});

  @override
  List<Object?> get props => [message];
}

class HadithLibraryBooksLoaded extends HadithLibraryState {
  final List<HadithBook> books;
  const HadithLibraryBooksLoaded({required this.books});

  @override
  List<Object?> get props => [books];
}

class HadithLibraryChaptersLoaded extends HadithLibraryState {
  final List<HadithChapter> chapters;
  const HadithLibraryChaptersLoaded({required this.chapters});

  @override
  List<Object?> get props => [chapters];
}

class HadithLibraryHadithsLoaded extends HadithLibraryState {
  final List<Hadith> hadiths;
  final bool hasReachedMax;
  final int currentPage;
  final bool isLoadingMore;

  const HadithLibraryHadithsLoaded({
    required this.hadiths,
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
    hadiths,
    hasReachedMax,
    currentPage,
    isLoadingMore,
  ];

  HadithLibraryHadithsLoaded copyWith({
    List<Hadith>? hadiths,
    bool? hasReachedMax,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return HadithLibraryHadithsLoaded(
      hadiths: hadiths ?? this.hadiths,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class HadithLibrarySearchResults extends HadithLibraryState {
  final List<Hadith> results;
  const HadithLibrarySearchResults({required this.results});

  @override
  List<Object?> get props => [results];
}
