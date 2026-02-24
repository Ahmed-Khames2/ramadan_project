class ArabicNormalization {
  /// Normalizes Arabic text by removing diacritics and unifying certain characters.
  /// This is essential for robust searching.
  static String normalize(String text) {
    if (text.isEmpty) return text;

    return text
        .replaceAll(
          RegExp(r'[\u064B-\u0652]'),
          '',
        ) // Remove Tashkeel (diacritics)
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }
}
