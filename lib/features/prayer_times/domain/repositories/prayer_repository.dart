import '../entities/prayer_time.dart';
import '../entities/governorate.dart';

abstract class PrayerRepository {
  List<PrayerTime> getPrayerTimes(Governorate governorate, DateTime date);
  List<Governorate> getGovernorates();
  List<PrayerTime> getPrayerTimesByCoordinates(
    double latitude,
    double longitude,
    DateTime date,
  );
}
