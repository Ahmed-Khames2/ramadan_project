import 'package:adhan/adhan.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/entities/governorate.dart';
import '../../domain/repositories/prayer_repository.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  @override
  List<Governorate> getGovernorates() {
    return const [
      Governorate(
        nameArabic: 'موقعي الحالي',
        nameEnglish: 'Current Location',
        latitude: 0.0,
        longitude: 0.0,
      ),
      Governorate(
        nameArabic: 'القاهرة',
        nameEnglish: 'Cairo',
        latitude: 30.0444,
        longitude: 31.2357,
      ),
      Governorate(
        nameArabic: 'الإسكندرية',
        nameEnglish: 'Alexandria',
        latitude: 31.2001,
        longitude: 29.9187,
      ),
      Governorate(
        nameArabic: 'الجيزة',
        nameEnglish: 'Giza',
        latitude: 30.0131,
        longitude: 31.2089,
      ),
      Governorate(
        nameArabic: 'الدقهلية',
        nameEnglish: 'Dakahlia',
        latitude: 31.0409,
        longitude: 31.3785,
      ),
      Governorate(
        nameArabic: 'البحر الأحمر',
        nameEnglish: 'Red Sea',
        latitude: 27.2579,
        longitude: 33.8116,
      ),
      Governorate(
        nameArabic: 'البحيرة',
        nameEnglish: 'Beheira',
        latitude: 31.0403,
        longitude: 30.4700,
      ),
      Governorate(
        nameArabic: 'الفيوم',
        nameEnglish: 'Fayoum',
        latitude: 29.3084,
        longitude: 30.8428,
      ),
      Governorate(
        nameArabic: 'الغربية',
        nameEnglish: 'Gharbia',
        latitude: 30.7865,
        longitude: 31.0004,
      ),
      Governorate(
        nameArabic: 'الإسماعيلية',
        nameEnglish: 'Ismailia',
        latitude: 30.5965,
        longitude: 32.2715,
      ),
      Governorate(
        nameArabic: 'المنوفية',
        nameEnglish: 'Menofia',
        latitude: 30.5503,
        longitude: 31.0090,
      ),
      Governorate(
        nameArabic: 'المنيا',
        nameEnglish: 'Minya',
        latitude: 28.0991,
        longitude: 30.7503,
      ),
      Governorate(
        nameArabic: 'القليوبية',
        nameEnglish: 'Qalyubia',
        latitude: 30.4578,
        longitude: 31.1822,
      ),
      Governorate(
        nameArabic: 'الوادي الجديد',
        nameEnglish: 'New Valley',
        latitude: 25.4390,
        longitude: 30.5586,
      ),
      Governorate(
        nameArabic: 'الشرقية',
        nameEnglish: 'Sharqia',
        latitude: 30.5877,
        longitude: 31.5020,
      ),
      Governorate(
        nameArabic: 'السويس',
        nameEnglish: 'Suez',
        latitude: 29.9668,
        longitude: 32.5498,
      ),
      Governorate(
        nameArabic: 'أسوان',
        nameEnglish: 'Aswan',
        latitude: 24.0889,
        longitude: 32.8998,
      ),
      Governorate(
        nameArabic: 'أسيوط',
        nameEnglish: 'Assiut',
        latitude: 27.1783,
        longitude: 31.1859,
      ),
      Governorate(
        nameArabic: 'بني سويف',
        nameEnglish: 'Beni Suef',
        latitude: 29.0744,
        longitude: 31.0979,
      ),
      Governorate(
        nameArabic: 'بورسعيد',
        nameEnglish: 'Port Said',
        latitude: 31.2653,
        longitude: 32.3019,
      ),
      Governorate(
        nameArabic: 'دمياط',
        nameEnglish: 'Damietta',
        latitude: 31.4175,
        longitude: 31.8144,
      ),
      Governorate(
        nameArabic: 'جنوب سيناء',
        nameEnglish: 'South Sinai',
        latitude: 28.5000,
        longitude: 34.0000,
      ),
      Governorate(
        nameArabic: 'كفر الشيخ',
        nameEnglish: 'Kafr El Sheikh',
        latitude: 31.1100,
        longitude: 30.9400,
      ),
      Governorate(
        nameArabic: 'مطروح',
        nameEnglish: 'Matrouh',
        latitude: 31.3543,
        longitude: 27.2373,
      ),
      Governorate(
        nameArabic: 'قنا',
        nameEnglish: 'Qena',
        latitude: 26.1551,
        longitude: 32.7160,
      ),
      Governorate(
        nameArabic: 'شمال سيناء',
        nameEnglish: 'North Sinai',
        latitude: 30.5000,
        longitude: 33.5000,
      ),
      Governorate(
        nameArabic: 'سوهاج',
        nameEnglish: 'Sohag',
        latitude: 26.5570,
        longitude: 31.6948,
      ),
      Governorate(
        nameArabic: 'الأقصر',
        nameEnglish: 'Luxor',
        latitude: 25.6872,
        longitude: 32.6396,
      ),
    ];
  }

  @override
  List<PrayerTime> getPrayerTimes(Governorate governorate, DateTime date) {
    final coordinates = Coordinates(
      governorate.latitude,
      governorate.longitude,
    );
    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes.today(coordinates, params);
    final next = prayerTimes.nextPrayer();

    return [
      PrayerTime(
        nameArabic: 'الفجر',
        nameEnglish: 'Fajr',
        time: prayerTimes.fajr,
        isCurrent: next == Prayer.fajr,
      ),
      PrayerTime(
        nameArabic: 'الظهر',
        nameEnglish: 'Dhuhr',
        time: prayerTimes.dhuhr,
        isCurrent: next == Prayer.dhuhr,
      ),
      PrayerTime(
        nameArabic: 'العصر',
        nameEnglish: 'Asr',
        time: prayerTimes.asr,
        isCurrent: next == Prayer.asr,
      ),
      PrayerTime(
        nameArabic: 'المغرب',
        nameEnglish: 'Maghrib',
        time: prayerTimes.maghrib,
        isCurrent: next == Prayer.maghrib,
      ),
      PrayerTime(
        nameArabic: 'العشاء',
        nameEnglish: 'Isha',
        time: prayerTimes.isha,
        isCurrent: next == Prayer.isha,
      ),
    ];
  }

  @override
  List<PrayerTime> getPrayerTimesByCoordinates(
    double latitude,
    double longitude,
    DateTime date,
  ) {
    final coordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes.today(coordinates, params);
    final next = prayerTimes.nextPrayer();

    return [
      PrayerTime(
        nameArabic: 'الفجر',
        nameEnglish: 'Fajr',
        time: prayerTimes.fajr,
        isCurrent: next == Prayer.fajr,
      ),
      PrayerTime(
        nameArabic: 'الظهر',
        nameEnglish: 'Dhuhr',
        time: prayerTimes.dhuhr,
        isCurrent: next == Prayer.dhuhr,
      ),
      PrayerTime(
        nameArabic: 'العصر',
        nameEnglish: 'Asr',
        time: prayerTimes.asr,
        isCurrent: next == Prayer.asr,
      ),
      PrayerTime(
        nameArabic: 'المغرب',
        nameEnglish: 'Maghrib',
        time: prayerTimes.maghrib,
        isCurrent: next == Prayer.maghrib,
      ),
      PrayerTime(
        nameArabic: 'العشاء',
        nameEnglish: 'Isha',
        time: prayerTimes.isha,
        isCurrent: next == Prayer.isha,
      ),
    ];
  }
}
