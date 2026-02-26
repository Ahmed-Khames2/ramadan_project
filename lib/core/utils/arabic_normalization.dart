class ArabicNormalization {
  /// Normalizes Arabic text by removing diacritics and unifying certain characters.
  /// This is essential for robust searching.
  static String normalize(String text) {
    if (text.isEmpty) return text;

    return text
        .replaceAll(RegExp(r'[\u064B-\u0652]'), '') // Remove Tashkeel
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  /// Generates a RegExp pattern that matches Arabic text while ignoring diacritics
  /// and treating different forms of letters (Alif, Taa Marbuta, etc.) as the same.
  static String searchPattern(String query) {
    if (query.isEmpty) return '';

    String pattern = '';
    final normalizedQuery = normalize(query);

    for (int i = 0; i < normalizedQuery.length; i++) {
      String char = normalizedQuery[i];
      if (char == 'ا') {
        pattern += '[اأإآ]';
      } else if (char == 'ه') {
        pattern += '[ههة]';
      } else if (char == 'ي') {
        pattern += '[يى]';
      } else {
        pattern += char;
      }
      // Allow any number of Arabic diacritics between characters
      pattern += '[\u064B-\u0652]*';
    }

    return pattern;
  }
}
