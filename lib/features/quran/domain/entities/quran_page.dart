import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';

class QuranPage {
  final int pageNumber;
  final int juzNumber;
  final String surahName;
  final List<Ayah> ayahs;

  QuranPage({
    required this.pageNumber,
    required this.juzNumber,
    required this.surahName,
    required this.ayahs,
  });
}
