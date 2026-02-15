import 'package:ramadan_project/features/audio/domain/entities/reciter.dart';


class Reciters {
  static const List<Reciter> all = [
    Reciter(
      id: 'ar.alafasy',
      name: 'Mishary Rashid Alafasy',
      arabicName: 'مشاري راشد العفاسي',
    ),
    Reciter(
      id: 'ar.husary',
      name: 'Mahmoud Khalil Al-Husary',
      arabicName: 'محمود خليل الحصري',
    ),
    Reciter(
      id: 'ar.mahermuaiqly',
      name: 'Maher Al Muaiqly',
      arabicName: 'ماهر المعيقلي',
    ),
    Reciter(
      id: 'ar.abdulbasitmurattal',
      name: 'Abdul Basit Abdul Samad (Murattal)',
      arabicName: 'عبد الباسط عبد الصمد (مرتل)',
    ),
  ];

  static const Reciter defaultReciter = Reciter(
    id: 'ar.alafasy',
    name: 'Mishary Rashid Alafasy',
    arabicName: 'مشاري راشد العفاسي',
  );
}
