import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/hadith.dart';
import '../../domain/repositories/hadith_repository.dart';

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
      final filtered = _allHadiths.where((hadith) {
        return hadith.title.contains(query) ||
            hadith.content.contains(query) ||
            hadith.description.contains(query);
      }).toList();
      emit(HadithLoaded(hadiths: _allHadiths, filteredHadiths: filtered));
    }
  }
}
