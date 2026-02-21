import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:quran/quran.dart' as quran_pkg;

class QuranSQLiteDataSource {
  Database? _db;

  Future<void> init() async {
    if (_db != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quran_v2.db');

    _db = await openDatabase(
      path,
      version: 2,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE ayahs ADD COLUMN normalized_text TEXT');
        }
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE surahs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            english_name TEXT,
            verse_count INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE ayahs (
            id INTEGER PRIMARY KEY,
            surah INTEGER,
            ayah INTEGER,
            text TEXT,
            normalized_text TEXT,
            translation TEXT,
            page INTEGER,
            juz INTEGER,
            is_sajda INTEGER
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_ayahs_normalized_text ON ayahs(normalized_text)',
        );
      },
    );

    // Note: Migration logic removed to reduce app size (no longer bundling raw JSONs).
    // In a real production app, you would bundle a pre-populated SQLite DB in assets
    // and copy it to the local app directory here.
  }

  String _normalizeArabic(String text) {
    if (text.isEmpty) return text;
    String normalized = text.replaceAll(RegExp(r'[\u064B-\u0652]'), '');
    normalized = normalized.replaceAll(
      RegExp(r'[\u0622\u0623\u0625]'),
      '\u0627',
    );
    normalized = normalized.replaceAll('\u0629', '\u0647');
    normalized = normalized.replaceAll('\u0649', '\u064A');
    return normalized.trim();
  }

  Future<List<Map<String, dynamic>>> getAyahsForPage(int page) async {
    return await _db!.query(
      'ayahs',
      where: 'page = ?',
      whereArgs: [page],
      orderBy: 'id ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAyahsForSurah(int surah) async {
    return await _db!.query(
      'ayahs',
      where: 'surah = ?',
      whereArgs: [surah],
      orderBy: 'ayah ASC',
    );
  }

  Future<String> getTafsir(int surah, int ayah) async {
    final results = await _db!.query(
      'ayahs',
      columns: ['translation'],
      where: 'surah = ? AND ayah = ?',
      whereArgs: [surah, ayah],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first['translation'] as String;
    }
    return "تفسير غير متاح";
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    final normalizedQuery = _normalizeArabic(query);

    final surahResults = await _db!.query(
      'surahs',
      where: 'name LIKE ? OR english_name LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      limit: 10,
    );

    final List<Map<String, dynamic>> combinedRaw = [];

    for (var s in surahResults) {
      combinedRaw.add({
        'type': 'surah',
        'surahNumber': s['id'],
        'text': s['name'],
        'subtitle': 'سورة ${s['name']} - ${s['verse_count']} آية',
      });
    }

    final ayahResults = await _db!.query(
      'ayahs',
      where: 'normalized_text LIKE ?',
      whereArgs: ['%$normalizedQuery%'],
      limit: 50,
    );

    for (var a in ayahResults) {
      combinedRaw.add({
        'type': 'ayah',
        'surahNumber': a['surah'],
        'ayahNumber': a['ayah'],
        'text': a['text'],
        'subtitle':
            '${quran_pkg.getSurahNameArabic(a['surah'] as int)} - آية ${a['ayah']}',
      });
    }

    return combinedRaw;
  }

  Future<int> getJuzStartPage(int juz) async {
    final result = await _db!.rawQuery(
      'SELECT MIN(page) as first_page FROM ayahs WHERE juz = ?',
      [juz],
    );
    return Sqflite.firstIntValue(result) ?? 1;
  }
}
