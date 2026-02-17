class KhatamPlan {
  final int pagesPerDay;
  final int todayTargetStartPage;
  final int todayTargetEndPage;
  final int dailyTargetStartPage;
  final int dailyTargetEndPage;
  final int remainingTodayPages;
  final int currentProgressPage;
  final double progressPercentage;
  final int remainingActiveDays;
  final bool isAhead;
  final int pagesDifference;
  final String statusMessage;
  final bool isRestDay;

  KhatamPlan({
    required this.pagesPerDay,
    required this.todayTargetStartPage,
    required this.todayTargetEndPage,
    required this.dailyTargetStartPage,
    required this.dailyTargetEndPage,
    required this.remainingTodayPages,
    required this.currentProgressPage,
    required this.progressPercentage,
    required this.remainingActiveDays,
    required this.isAhead,
    required this.pagesDifference,
    required this.statusMessage,
    this.isRestDay = false,
  });
}
