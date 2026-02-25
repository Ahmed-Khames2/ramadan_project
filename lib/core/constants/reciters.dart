import 'package:ramadan_project/features/audio/domain/entities/reciter.dart';

class Reciters {
  static const List<Reciter> all = [
    Reciter(
      id: 'ar.alafasy',
      name: 'Mishary Rashid Alafasy',
      arabicName: 'مشاري راشد العفاسي',
    ),

    Reciter(
      id: 'ar.mahermuaiqly',
      name: 'Maher Al Muaiqly',
      arabicName: 'ماهر المعيقلي',
    ),
    Reciter(
      id: 'ar.ahmedajamy',
      name: 'Ahmed ibn Ali al-Ajamy',
      arabicName: 'أحمد علي العجمي',
    ),
  ];

  static const Reciter defaultReciter = Reciter(
    id: 'ar.alafasy',
    name: 'Mishary Rashid Alafasy',
    arabicName: 'مشاري راشد العفاسي',
  );
}
