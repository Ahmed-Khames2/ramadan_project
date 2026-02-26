extension StringArabicNum on String {
  String toArabicNumbers() {
    const englishNumbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String output = this;
    for (int i = 0; i < englishNumbers.length; i++) {
      output = output.replaceAll(englishNumbers[i], arabicNumbers[i]);
    }
    return output;
  }
}

extension IntArabicNum on int {
  String toArabic() => toString().toArabicNumbers();
}

extension DoubleArabicNum on double {
  String toArabic({int fractionDigits = 1}) =>
      toStringAsFixed(fractionDigits).toArabicNumbers();
}
