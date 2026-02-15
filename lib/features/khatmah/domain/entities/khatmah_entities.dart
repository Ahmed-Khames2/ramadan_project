import 'package:hive/hive.dart';


@HiveType(typeId: 2)
class KhatmahPlan extends HiveObject {
  @HiveField(0)
  final DateTime startDate;

  @HiveField(1)
  final int targetDays;

  @HiveField(2)
  final bool restDaysEnabled;

  @HiveField(3)
  final List<int> restDays; // 1-7 for Mon-Sun

  @HiveField(4)
  int currentProgressPage;

  @HiveField(5)
  bool isPaused;

  @HiveField(6)
  DateTime? lastReadAt;

  @HiveField(7)
  Map<String, int> dailyPagesRead; // Key: "yyyy-MM-dd", Value: pages count

  @HiveField(8)
  String? title;

  KhatmahPlan({
    required this.startDate,
    required this.targetDays,
    this.restDaysEnabled = false,
    this.restDays = const [],
    this.currentProgressPage = 0,
    this.isPaused = false,
    this.lastReadAt,
    this.dailyPagesRead = const {},
    this.title = 'ختمة جديدة',
  });
}

@HiveType(typeId: 3)
class KhatmahHistoryEntry extends HiveObject {
  @HiveField(0)
  final DateTime startDate;

  @HiveField(1)
  final DateTime completionDate;

  @HiveField(2)
  final int totalDays;

  @HiveField(3)
  final String title;

  KhatmahHistoryEntry({
    required this.startDate,
    required this.completionDate,
    required this.totalDays,
    required this.title,
  });
}

@HiveType(typeId: 4)
class KhatmahMilestone extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime unlockedAt;

  @HiveField(3)
  final String icon;

  KhatmahMilestone({
    required this.id,
    required this.title,
    required this.unlockedAt,
    required this.icon,
  });
}
