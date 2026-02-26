extension ArabicDigits on String {
  static const List<String> _arabicDigits = [
    '٠',
    '١',
    '٢',
    '٣',
    '٤',
    '٥',
    '٦',
    '٧',
    '٨',
    '٩',
  ];

  String toArabicDigits() {
    final buffer = StringBuffer();
    for (final codeUnit in codeUnits) {
      final digit = codeUnit - 48;
      if (digit >= 0 && digit <= 9) {
        buffer.write(_arabicDigits[digit]);
      } else {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }
}

extension IntArabicDigits on int {
  String toArabicDigits() => toString().toArabicDigits();

  String toJuzName() {
    const juzNames = {
      1: 'الجزء الأول',
      2: 'الجزء الثاني',
      3: 'الجزء الثالث',
      4: 'الجزء الرابع',
      5: 'الجزء الخامس',
      6: 'الجزء السادس',
      7: 'الجزء السابع',
      8: 'الجزء الثامن',
      9: 'الجزء التاسع',
      10: 'الجزء العاشر',
      11: 'الجزء الحادي عشر',
      12: 'الجزء الثاني عشر',
      13: 'الجزء الثالث عشر',
      14: 'الجزء الرابع عشر',
      15: 'الجزء الخامس عشر',
      16: 'الجزء السادس عشر',
      17: 'الجزء السابع عشر',
      18: 'الجزء الثامن عشر',
      19: 'الجزء التاسع عشر',
      20: 'الجزء العشرون',
      21: 'الجزء الحادي والعشرون',
      22: 'الجزء الثاني والعشرون',
      23: 'الجزء الثالث والعشرون',
      24: 'الجزء الرابع والعشرون',
      25: 'الجزء الخامس والعشرون',
      26: 'الجزء السادس والعشرون',
      27: 'الجزء السابع والعشرون',
      28: 'الجزء الثامن والعشرون',
      29: 'الجزء التاسع والعشرون',
      30: 'الجزء الثلاثون',
    };
    return juzNames[this] ?? 'الجزء ${this.toArabicDigits()}';
  }
}
