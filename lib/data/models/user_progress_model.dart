import 'package:hive/hive.dart';

part 'user_progress_model.g.dart';

@HiveType(typeId: 0)
class UserProgressModel extends HiveObject {
  @HiveField(0)
  int? lastReadPage;

  @HiveField(1)
  int? lastReadAyahId;

  @HiveField(2)
  List<int>? bookmarks;

  @HiveField(3)
  List<int>? favorites;

  @HiveField(4)
  int? targetDays; // For Khatam Planner

  @HiveField(5)
  DateTime? startDate; // For Khatam Planner

  @HiveField(6)
  double? scrollOffset; // For scroll position

  @HiveField(7)
  int? lastReadSurahNumber; // For Surah tracking

  UserProgressModel({
    this.lastReadPage,
    this.lastReadAyahId,
    this.bookmarks,
    this.favorites,
    this.targetDays,
    this.startDate,
    this.scrollOffset,
    this.lastReadSurahNumber,
  });
}
