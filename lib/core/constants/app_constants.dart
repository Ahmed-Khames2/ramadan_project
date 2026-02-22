class AppConstants {
  static const String appName = 'زاد';
  static const String downloadUrl =
      'https://example.com/zad_latest.apk'; // TODO: Update with actual link

  static String get shareMessage =>
      'حمل تطبيق "زاد": رفيقك للقرآن والأذكار ومواقيت الصلاة.\n\nرابط التحميل: $downloadUrl';

  static String verseShareMessage(String text, String surah, int ayah) =>
      '$text\n\n[$surah - آية $ayah]\n\nتمت المشاركة من تطبيق "زاد"\nتحميل التطبيق: $downloadUrl';
}
