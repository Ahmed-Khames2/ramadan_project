import 'package:hijri/hijri_calendar.dart';

class HijriUtils {
  /// Returns a Hijri calendar adjusted by -1 day to align with local moon sighting.
  /// As requested, this makes February 19, 2026, correspond to 1 Ramadan 1447.
  static HijriCalendar getAdjustedHijri(DateTime date) {
    HijriCalendar.setLocal('ar');
    return HijriCalendar.fromDate(date.subtract(const Duration(days: 1)));
  }

  /// Formats a Hijri date as a string.
  static String formatHijri(HijriCalendar hijri) {
    return '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}';
  }
}
