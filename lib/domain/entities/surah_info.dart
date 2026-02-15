class SurahInfo {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String revelationType; // 'Meccan' or 'Medinan'
  final int ayahCount;
  final int startPage;

  SurahInfo({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.revelationType,
    required this.ayahCount,
    required this.startPage,
  });

  bool get isMakki =>
      revelationType.toLowerCase().contains('makk') ||
      revelationType.toLowerCase().contains('mecc');
  bool get isMadani => revelationType.toLowerCase().contains('madin');
}
