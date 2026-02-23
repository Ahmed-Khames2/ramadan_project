part of 'hadith_cubit.dart';

abstract class HadithState {}

class HadithInitial extends HadithState {}

class HadithLoading extends HadithState {}

class HadithLoaded extends HadithState {
  final List<Hadith> hadiths;
  final List<Hadith> filteredHadiths;

  HadithLoaded({required this.hadiths, required this.filteredHadiths});
}

class HadithError extends HadithState {
  final String message;

  HadithError(this.message);
}
