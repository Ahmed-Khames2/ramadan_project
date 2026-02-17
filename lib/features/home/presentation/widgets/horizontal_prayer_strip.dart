import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/prayer_times/presentation/bloc/prayer_bloc.dart';
import 'package:ramadan_project/features/prayer_times/domain/entities/prayer_time.dart';

class HorizontalPrayerStrip extends StatelessWidget {
  const HorizontalPrayerStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        if (state is PrayerLoaded) {
          return SizedBox(
            height: 100, // Fixed height for the strip
            child: ListView.separated(
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
    final backgroundColor = isCurrent ? AppTheme.primaryEmerald : Colors.white;
    final textColor = isCurrent ? Colors.white : AppTheme.textDark;
    final timeColor = isCurrent
        ? Colors.white.withOpacity(0.9)
        : AppTheme.primaryEmerald;
    final borderColor = isCurrent
        ? Colors.transparent
        : AppTheme.primaryEmerald.withOpacity(0.2);

    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppTheme.primaryEmerald.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            prayer.nameArabic,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('h:mm a').format(prayer.time),
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: timeColor,
            ),
          ),
        ],
      ),
    );
  }
}
