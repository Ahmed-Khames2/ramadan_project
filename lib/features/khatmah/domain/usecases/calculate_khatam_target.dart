import '../entities/khatam_plan.dart';

class CalculateKhatamTarget {
  // Saudi Quran is 604 pages usually.
  static const int TOTAL_PAGES = 604;

  KhatamPlan call({
    required int targetDays,
    required int currentProgressPage,
    required DateTime startDate,
    required bool restDaysEnabled,
    required List<int> restDays,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(startDate.year, startDate.month, startDate.day);

    // Total duration in days including today
    final totalDuration = targetDays;
    final endDate = startDay.add(Duration(days: totalDuration - 1));

    // Calculate remaining active days (excluding rest days)
    int remainingActiveDays = 0;
    DateTime dateRunner = today;

    while (!dateRunner.isAfter(endDate)) {
      bool isRestDay = restDaysEnabled && restDays.contains(dateRunner.weekday);
      if (!isRestDay) {
        remainingActiveDays++;
      }
      dateRunner = dateRunner.add(const Duration(days: 1));
    }

    int remainingPages = TOTAL_PAGES - currentProgressPage;
    if (remainingPages < 0) remainingPages = 0;

    int pagesPerDay = remainingActiveDays > 0
        ? (remainingPages / remainingActiveDays).ceil()
        : remainingPages;

    bool isTodayRestDay = restDaysEnabled && restDays.contains(today.weekday);

    int startPage = currentProgressPage + 1;
    int endPage = isTodayRestDay
        ? currentProgressPage
        : startPage + pagesPerDay - 1;

    if (endPage > TOTAL_PAGES) endPage = TOTAL_PAGES;
    if (startPage > TOTAL_PAGES) startPage = TOTAL_PAGES;

    // Progress percentage
    double progressPercentage = (currentProgressPage / TOTAL_PAGES) * 100;

    // Ahead/Behind logic
    // Expected active days passed since start
    int activeDaysPassed = 0;
    dateRunner = startDay;
    while (dateRunner.isBefore(today)) {
      bool isRestWeekDay =
          restDaysEnabled && restDays.contains(dateRunner.weekday);
      if (!isRestWeekDay) activeDaysPassed++;
      dateRunner = dateRunner.add(const Duration(days: 1));
    }

    // Total active days in plan
    int totalActiveDays = 0;
    dateRunner = startDay;
    while (!dateRunner.isAfter(endDate)) {
      bool isRestWeekDay =
          restDaysEnabled && restDays.contains(dateRunner.weekday);
      if (!isRestWeekDay) totalActiveDays++;
      dateRunner = dateRunner.add(const Duration(days: 1));
    }

    double expectedPage = totalActiveDays > 0
        ? (TOTAL_PAGES / totalActiveDays) * activeDaysPassed
        : 0;

    int pagesDifference = currentProgressPage - expectedPage.round();
    bool isAhead = pagesDifference >= 0;

    String statusMessage = isTodayRestDay
        ? "اليوم يوم راحة ☕"
        : "تبقي $remainingPages صفحة على الختمة";

    return KhatamPlan(
      pagesPerDay: pagesPerDay,
      todayTargetStartPage: startPage,
      todayTargetEndPage: endPage,
      currentProgressPage: currentProgressPage,
      progressPercentage: progressPercentage,
      remainingActiveDays: remainingActiveDays,
      isAhead: isAhead,
      pagesDifference: pagesDifference.abs(),
      statusMessage: statusMessage,
      isRestDay: isTodayRestDay,
    );
  }
}
