import 'package:quran/quran.dart' as quran;

void main() {
  print("Exploring quran package...");
  // Check common method names
  try {
    print("Sura 1 Ayah 1 Juz: ${quran.getJuzNumber(1, 1)}");
  } catch (e) {
    print("getJuzNumber failed: $e");
  }

  // Check if getHizbNumber exists
  try {
    // This is a guess
    // print("Hizb Number: ${quran.getHizbNumber(1, 1)}");
  } catch (e) {
    // print("getHizbNumber does not exist");
  }
}
