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
}
