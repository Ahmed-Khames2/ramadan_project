import 'dart:async';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:ramadan_project/core/utils/string_extensions.dart';
import 'package:ramadan_project/features/prayer_times/domain/entities/prayer_time.dart';

class AccuratePrayerCountdown extends StatefulWidget {
  final List<PrayerTime> prayers;

  const AccuratePrayerCountdown({super.key, required this.prayers});

  @override
  State<AccuratePrayerCountdown> createState() =>
      _AccuratePrayerCountdownState();
}

class _AccuratePrayerCountdownState extends State<AccuratePrayerCountdown> {
  Timer? _timer;
  PrayerTime? _nextPrayer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void didUpdateWidget(covariant AccuratePrayerCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTime();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    PrayerTime? next;

    // Find next prayer
    for (final prayer in widget.prayers) {
      if (prayer.time.isAfter(now)) {
        next = prayer;
        break;
      }
    }

    // Fallback: If no prayer is after now, it means next is Fajr tomorrow
    if (next == null && widget.prayers.isNotEmpty) {
      final fajrToday = widget.prayers.first;
      final tomorrowFajrTime = fajrToday.time.add(const Duration(days: 1));

      next = PrayerTime(
        nameArabic: fajrToday.nameArabic,
        nameEnglish: fajrToday.nameEnglish,
        time: tomorrowFajrTime,
        isCurrent: false,
      );
    }

    if (next == null) {
      // Logic to handle next day Fajr
      // Assuming the first prayer in list is Fajr
      final fajrToday = widget.prayers.first;
      // create a new PrayerTime for tomorrow's Fajr (approx)
      // Ideally we should have tomorrow's prayer times, but for now adding 24h to today's Fajr is a decent fallback for the countdown visual.
      final tomorrowFajrTime = fajrToday.time.add(const Duration(days: 1));
      next = PrayerTime(
        nameArabic: fajrToday.nameArabic,
        nameEnglish: fajrToday.nameEnglish,
        time: tomorrowFajrTime,
        isCurrent: false,
      );
    }

    if (mounted) {
      setState(() {
        _nextPrayer = next;
        _timeLeft = next!.time.difference(now);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_nextPrayer == null) return const SizedBox.shrink();

    final hours = _timeLeft.inHours;
    final minutes = _timeLeft.inMinutes % 60;

    String _formatArabicTimeLeft(int hours, int minutes) {
      if (hours == 0 && minutes == 0) {
        return 'حان الآن وقت الصلاة';
      }

      String hoursText = '';
      if (hours == 1) {
        hoursText = 'ساعة';
      } else if (hours == 2) {
        hoursText = 'ساعتان';
      } else if (hours >= 3 && hours <= 10) {
        hoursText = '${hours.toArabic()} ساعات';
      } else if (hours > 10) {
        hoursText = '${hours.toArabic()} ساعة';
      }

      String minutesText = '';
      if (minutes == 1) {
        minutesText = 'دقيقة';
      } else if (minutes == 2) {
        minutesText = 'دقيقتان';
      } else if (minutes >= 3 && minutes <= 10) {
        minutesText = '${minutes.toArabic()} دقائق';
      } else if (minutes > 10) {
        minutesText = '${minutes.toArabic()} دقيقة';
      }

      if (hoursText.isEmpty && minutesText.isEmpty) {
        return '';
      } else if (hoursText.isNotEmpty && minutesText.isEmpty) {
        return 'متبقي $hoursText';
      } else if (hoursText.isEmpty && minutesText.isNotEmpty) {
        return 'متبقي $minutesText';
      } else {
        return 'متبقي $hoursText و $minutesText';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
      child: IslamicCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryEmerald,
                AppTheme.primaryEmerald.withOpacity(0.85),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(
                  Icons.mosque_outlined,
                  size: 150,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing6),
                child: Column(
                  children: [
                    Text(
                      'الصلاة القادمة: ${_nextPrayer!.nameArabic}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Text(
                      DateFormat.jm(
                        'ar',
                      ).format(_nextPrayer!.time).toArabicNumbers(),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 18,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatArabicTimeLeft(hours, minutes),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
