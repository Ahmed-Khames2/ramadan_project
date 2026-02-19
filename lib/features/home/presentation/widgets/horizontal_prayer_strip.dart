import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/prayer_times/presentation/bloc/prayer_bloc.dart';
import 'package:ramadan_project/features/prayer_times/domain/entities/prayer_time.dart';

class HorizontalPrayerStrip extends StatefulWidget {
  const HorizontalPrayerStrip({super.key});

  @override
  State<HorizontalPrayerStrip> createState() => _HorizontalPrayerStripState();
}

class _HorizontalPrayerStripState extends State<HorizontalPrayerStrip> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentPrayer(List<PrayerTime> prayers) {
    if (!mounted) return;

    final currentIndex = prayers.indexWhere((p) => p.isCurrent);
    if (currentIndex != -1) {
      // Item width (90) + separator (12)
      const double itemWidth = 90;
      const double separatorWidth = 12;

      // Calculate scroll position to center the current prayer
      // Screen width is needed for perfect centering, but scrolling to start of item is usually enough
      // or offsetting it slightly.
      final double offset = currentIndex * (itemWidth + separatorWidth);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrayerBloc, PrayerState>(
      listener: (context, state) {
        if (state is PrayerLoaded) {
          _scrollToCurrentPrayer(state.prayerTimes);
        }
      },
      builder: (context, state) {
        if (state is PrayerLoaded) {
          // Trigger initial scroll
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToCurrentPrayer(state.prayerTimes);
          });

          return SizedBox(
            height: 125,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: state.prayerTimes.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppTheme.spacing3),
              itemBuilder: (context, index) {
                final prayer = state.prayerTimes[index];
                return _PrayerItem(prayer: prayer, isCurrent: prayer.isCurrent);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _PrayerItem extends StatelessWidget {
  final PrayerTime prayer;
  final bool isCurrent;

  const _PrayerItem({required this.prayer, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isCurrent
        ? AppTheme.primaryEmerald
        : theme.cardColor;
    final textColor = isCurrent ? Colors.white : theme.colorScheme.onSurface;
    final timeColor = isCurrent
        ? Colors.white.withOpacity(0.9)
        : (isDark ? theme.colorScheme.secondary : theme.colorScheme.primary);
    final borderColor = isCurrent
        ? Colors.transparent
        : (isDark
              ? Colors.white.withOpacity(0.1)
              : theme.colorScheme.primary.withOpacity(0.2));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: isCurrent
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryEmerald,
                  AppTheme.primaryEmerald.withOpacity(0.8),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppTheme.primaryEmerald.withOpacity(0.35),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: -2,
                ),
              ]
            : [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Prayer Icon with subtle glow if current
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrent
                  ? Colors.white.withOpacity(0.15)
                  : theme.colorScheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getPrayerIcon(prayer.nameEnglish),
              size: 22,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          // Prayer Name
          Text(
            prayer.nameArabic,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          // Prayer Time
          Text(
            DateFormat('h:mm a', 'ar').format(prayer.time),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: timeColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight_rounded;
      case 'dhuhr':
        return Icons.wb_sunny_rounded;
      case 'asr':
        return Icons.wb_cloudy_rounded;
      case 'maghrib':
        return Icons.nights_stay_rounded;
      case 'isha':
        return Icons.bedtime_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }
}
