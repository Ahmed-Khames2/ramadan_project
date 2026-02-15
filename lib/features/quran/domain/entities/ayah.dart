import 'package:equatable/equatable.dart';

class Ayah extends Equatable {
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final int pageNumber;
  final int globalAyahNumber;
  final String surahName;
  final bool isSajda;

  const Ayah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    required this.pageNumber,
    this.globalAyahNumber = 0,
    this.surahName = '',
    this.isSajda = false,
  });

  @override
  List<Object?> get props => [
    surahNumber,
    ayahNumber,
    text,
    pageNumber,
    globalAyahNumber,
    surahName,
    isSajda,
  ];
}
