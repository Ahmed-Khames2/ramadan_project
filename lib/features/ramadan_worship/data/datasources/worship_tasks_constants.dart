import 'package:ramadan_project/features/ramadan_worship/domain/entities/worship_task.dart';

class WorshipTasksConstants {
  static List<WorshipTask> get defaultTasks => [
    // Prayers
    const WorshipTask(
      id: 'fajr',
      title: 'صلاة الفجر',
      type: WorshipTaskType.prayer,
    ),
    const WorshipTask(
      id: 'dhuhr',
      title: 'صلاة الظهر',
      type: WorshipTaskType.prayer,
    ),
    const WorshipTask(
      id: 'asr',
      title: 'صلاة العصر',
      type: WorshipTaskType.prayer,
    ),
    const WorshipTask(
      id: 'maghrib',
      title: 'صلاة المغرب',
      type: WorshipTaskType.prayer,
    ),
    const WorshipTask(
      id: 'isha',
      title: 'صلاة العشاء',
      type: WorshipTaskType.prayer,
    ),

    // Sunnah Prayers
    const WorshipTask(
      id: 'taraweeh',
      title: 'صلاة التراويح',
      type: WorshipTaskType.checkbox,
    ),
    const WorshipTask(
      id: 'qiyam',
      title: 'قيام الليل',
      type: WorshipTaskType.checkbox,
    ),

    // Quran
    const WorshipTask(
      id: 'quran',
      title: 'ورد القرآن',
      type: WorshipTaskType.count,
      target: 20, // Default 1 Juz (20 pages)
      isEditable: true,
    ),

    // Adhkar
    const WorshipTask(
      id: 'morning_adhkar',
      title: 'أذكار الصباح',
      type: WorshipTaskType.checkbox,
    ),
    const WorshipTask(
      id: 'evening_adhkar',
      title: 'أذكار المساء',
      type: WorshipTaskType.checkbox,
    ),
    const WorshipTask(
      id: 'dua',
      title: 'الدعاء',
      type: WorshipTaskType.checkbox,
    ),

    // Tasbeeh & Istighfar
    const WorshipTask(
      id: 'tasbeeh',
      title: 'التسبيح',
      type: WorshipTaskType.count,
      target: 100,
      isEditable: true,
    ),
    const WorshipTask(
      id: 'istighfar',
      title: 'الاستغفار',
      type: WorshipTaskType.count,
      target: 100,
      isEditable: true,
    ),
  ];
}
