import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/hadith.dart';
import '../../domain/repositories/hadith_library_repository.dart';

abstract class HadithChaptersState extends Equatable {
  const HadithChaptersState();
  @override
  List<Object?> get props => [];
}

class HadithChaptersInitial extends HadithChaptersState {}

class HadithChaptersLoading extends HadithChaptersState {}

class HadithChaptersLoaded extends HadithChaptersState {
  final List<HadithChapter> chapters;
  const HadithChaptersLoaded({required this.chapters});
  @override
  List<Object?> get props => [chapters];
}

class HadithChaptersError extends HadithChaptersState {
  final String message;
  const HadithChaptersError({required this.message});
  @override
  List<Object?> get props => [message];
}

class HadithChaptersCubit extends Cubit<HadithChaptersState> {
  final HadithLibraryRepository repository;

  HadithChaptersCubit({required this.repository})
    : super(HadithChaptersInitial());

  Future<void> loadChapters(String bookKey) async {
    emit(HadithChaptersLoading());
    try {
      final chapters = await repository.getChapters(bookKey);
      emit(HadithChaptersLoaded(chapters: chapters));
    } catch (e) {
      emit(HadithChaptersError(message: e.toString()));
    }
  }
}
