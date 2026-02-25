import 'package:quran/quran.dart' as quran;

void main() {
  // Page 2 ends with Baqarah 25, Page 3 starts with Baqarah 26
  print("Baqarah 25 page: " + quran.getPageNumber(2, 25).toString());
  print("Page 2 data: " + quran.getPageData(2).toString());

  // Page 4 ends with Baqarah 37, Page 5 starts with 38
  print("Baqarah 37 page: " + quran.getPageNumber(2, 37).toString());
  print("Page 4 data: " + quran.getPageData(4).toString());
}
