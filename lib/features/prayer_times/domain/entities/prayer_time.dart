class PrayerTime {
  final String nameArabic;
  final String nameEnglish;
  final DateTime time;
  final bool isCurrent;

  PrayerTime({
    required this.nameArabic,
    required this.nameEnglish,
    required this.time,
    this.isCurrent = false,
  });
}
