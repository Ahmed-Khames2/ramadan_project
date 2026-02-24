class FilePathManager {
  static const String hadithBaseDir = 'assets/json/hadiss/';

  static const Map<String, int> books = {
    'bukhari': 97,
    'muslim': 57,
    'abudawud': 43,
    'tirmidhi': 49,
  };

  static String getBookHadithPath(String book, int fileNumber) {
    return '$hadithBaseDir$book/$fileNumber.json';
  }

  static List<String> getAllBookKeys() {
    return books.keys.toList();
  }

  static int getFileCountForBook(String book) {
    return books[book] ?? 0;
  }
}
