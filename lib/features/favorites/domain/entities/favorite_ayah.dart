import 'package:hive/hive.dart';

part 'favorite_ayah.g.dart';

@HiveType(typeId: 1)
class FavoriteAyah extends HiveObject {
  @HiveField(0)
  final int surahNumber;

  @HiveField(1)
  final int ayahNumber;

  @HiveField(2)
  final int globalAyahNumber;

  @HiveField(3)
  final String text;

  @HiveField(4)
  final String surahName;

  @HiveField(5)
  final DateTime addedAt;

  FavoriteAyah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.globalAyahNumber,
    required this.text,
    required this.surahName,
    required this.addedAt,
  });
}
