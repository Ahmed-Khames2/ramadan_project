import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/hadith.dart';
import '../../domain/repositories/hadith_repository.dart';
import 'package:ramadan_project/core/utils/arabic_normalization.dart';

part 'hadith_state.dart';

class HadithCubit extends Cubit<HadithState> {
  final HadithRepository repository;
  List<Hadith> _allHadiths = [];

  HadithCubit({required this.repository}) : super(HadithInitial());

  Future<void> loadHadiths() async {
    emit(HadithLoading());
    try {
      final hadiths = await repository.getHadiths();
      _allHadiths = hadiths;
      emit(HadithLoaded(hadiths: _allHadiths, filteredHadiths: _allHadiths));
    } catch (e) {
      emit(HadithError(e.toString()));
    }
  }

  void searchHadiths(String query) {
    if (state is HadithLoaded) {
      if (query.isEmpty) {
        emit(HadithLoaded(hadiths: _allHadiths, filteredHadiths: _allHadiths));
        return;
      }

      final normalizedQuery = ArabicNormalization.normalize(
        query.toLowerCase(),
      );

      final filtered = _allHadiths.where((hadith) {
        final normalizedTitle = ArabicNormalization.normalize(
          hadith.title.toLowerCase(),
        );
        final normalizedContent = ArabicNormalization.normalize(
          hadith.content.toLowerCase(),
        );
        final normalizedDescription = ArabicNormalization.normalize(
          hadith.description.toLowerCase(),
        );

        return normalizedTitle.contains(normalizedQuery) ||
            normalizedContent.contains(normalizedQuery) ||
            normalizedDescription.contains(normalizedQuery);
      }).toList();
      emit(HadithLoaded(hadiths: _allHadiths, filteredHadiths: filtered));
    }
  }
}
