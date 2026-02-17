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

    // Calculate Fixed Daily Target (Theoretical)
    // How many active days have passed including today
    int totalActiveDaysPassed = 0;
    dateRunner = startDay;
    while (!dateRunner.isAfter(today)) {
      bool isRestWeekDay =
          restDaysEnabled && restDays.contains(dateRunner.weekday);
      if (!isRestWeekDay) totalActiveDaysPassed++;
      dateRunner = dateRunner.add(const Duration(days: 1));
    }

    // Average pages per active day (from start)
    // We can assume totalActiveDays from original plan
    int totalActiveDaysPlan = 0;
    dateRunner = startDay;
    DateTime planEndDate = startDay.add(Duration(days: targetDays - 1));
    while (!dateRunner.isAfter(planEndDate)) {
      bool isRestWeekDay =
          restDaysEnabled && restDays.contains(dateRunner.weekday);
      if (!isRestWeekDay) totalActiveDaysPlan++;
      dateRunner = dateRunner.add(const Duration(days: 1));
    }

    double avgPagesPerDay = totalActiveDaysPlan > 0
        ? TOTAL_PAGES / totalActiveDaysPlan
        : 0;

    int dailyTargetStart = isTodayRestDay
        ? 0
        : ((totalActiveDaysPassed - 1) * avgPagesPerDay).floor() + 1;
    int dailyTargetEnd = isTodayRestDay
        ? 0
        : (totalActiveDaysPassed * avgPagesPerDay).floor();

    // SMART SHIFTING: If user finished today's target, show tomorrow's target
    bool isTodayFinished =
        currentProgressPage >= dailyTargetEnd && dailyTargetEnd > 0;
    if (isTodayFinished) {
      // Find next active day to show its target
      int nextActiveDayIndex = totalActiveDaysPassed + 1;
      dailyTargetStart =
          ((nextActiveDayIndex - 1) * avgPagesPerDay).floor() + 1;
      dailyTargetEnd = (nextActiveDayIndex * avgPagesPerDay).floor();
    }

    if (dailyTargetEnd > TOTAL_PAGES) dailyTargetEnd = TOTAL_PAGES;
    if (dailyTargetStart > TOTAL_PAGES) dailyTargetStart = TOTAL_PAGES;
    if (dailyTargetStart < 0) dailyTargetStart = 0;

    int remainingToday = dailyTargetEnd - currentProgressPage;
    if (remainingToday < 0) remainingToday = 0;

    // Progress percentage
    double progressPercentage = (currentProgressPage / TOTAL_PAGES) * 100;

    // Ahead/Behind logic
    int activeDaysPassedBeforeToday = totalActiveDaysPassed - 1;
    double expectedPage = avgPagesPerDay * activeDaysPassedBeforeToday;

    int pagesDifference = currentProgressPage - expectedPage.round();
    bool isAhead = pagesDifference >= 0;

    String statusMessage = isTodayRestDay
        ? "اليوم يوم راحة ☕"
        : isTodayFinished
        ? "أتممت ورد اليوم! أنت الآن تقرأ مسبقاً 🚀"
        : "تبقي $remainingPages صفحة على الختمة";

    return KhatamPlan(
      pagesPerDay: pagesPerDay,
      todayTargetStartPage: startPage,
      todayTargetEndPage: endPage,
      dailyTargetStartPage: dailyTargetStart,
      dailyTargetEndPage: dailyTargetEnd,
      remainingTodayPages: remainingToday,
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
