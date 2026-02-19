import 'dart:io' if (dart.library.html) 'dart:html' show Platform;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ramadan_project/features/prayer_times/domain/entities/prayer_time.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  Future<void> schedulePrayerNotifications(
    List<PrayerTime> prayers,
    int minutesBefore,
  ) async {
    try {
      await cancelAllNotifications();

      bool canScheduleExact = true;
      if (!kIsWeb && Platform.isAndroid) {
        final bool? exactAlarmsPermitted = await _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.canScheduleExactNotifications();
        canScheduleExact = exactAlarmsPermitted ?? false;
      }

      for (int i = 0; i < prayers.length; i++) {
        final prayer = prayers[i];
        final scheduledTime = prayer.time.subtract(
          Duration(minutes: minutesBefore),
        );

        if (scheduledTime.isBefore(DateTime.now())) continue;

        await _notifications.zonedSchedule(
          i,
          'تنبيه الصلاة',
          'اقترب موعد صلاة ${prayer.nameArabic}. استعد للصلاة.',
          tz.TZDateTime.from(scheduledTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_alerts',
              'Prayer Alerts',
              channelDescription: 'Notifications for upcoming prayers',
              importance: Importance.max,
              priority: Priority.high,
              // Add a default sound/vibrate to ensure it's visible
              sound: const RawResourceAndroidNotificationSound('notification'),
              playSound: true,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: canScheduleExact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
    }
  }

  Future<void> requestPermissions() async {
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleKhatmahReminders({
    required String title,
    required String portion,
    required int hour,
    required int minute,
  }) async {
    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        100, // Fixed ID for daily reminder
        'تذكير الختمة: $title',
        'وردك لليوم: $portion. لا تؤجل عمل اليوم إلى الغد.',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'khatmah_reminders',
            'Khatmah Reminders',
            channelDescription:
                'Daily reminders for your Quran completion plan',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling khatmah reminder: $e');
    }
  }

  Future<void> cancelKhatmahReminders() async {
    await _notifications.cancel(100);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
