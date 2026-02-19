import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/prayer_times/presentation/bloc/prayer_bloc.dart';
import 'package:ramadan_project/features/prayer_times/domain/entities/governorate.dart';

class CustomHomeHeader extends StatelessWidget {
  const CustomHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Hijri Date
    HijriCalendar.setLocal('ar');
    // Hikri Date Correction: Subtract 1 day to match local sighting
    final hijriDate = HijriCalendar.fromDate(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    final hijriString =
        '${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear}';

    // Gregorian Date
    final now = DateTime.now();
    final gregorianString = DateFormat('EEEE، d MMMM yyyy', 'ar').format(now);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date Section (Right Side for RTL)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hijriString,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                gregorianString,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),

          // Location Section (Left Side for RTL)
          BlocBuilder<PrayerBloc, PrayerState>(
            builder: (context, state) {
              if (state is PrayerLoaded) {
                return _buildLocationSelector(context, state);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelector(BuildContext context, PrayerLoaded state) {
    // Find the matching governorate in the list to set as initial value
    // This handles the case where selectedGovernorate has a dynamic Arabic name
    // but corresponds to the "Current Location" item in the list.
    final selectedInList = state.governorates.firstWhere(
      (g) => g.nameEnglish == state.selectedGovernorate.nameEnglish,
      orElse: () => state.selectedGovernorate,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryEmerald.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryEmerald.withOpacity(0.2)),
      ),
      child: PopupMenuButton<Governorate>(
        initialValue: selectedInList,
        position: PopupMenuPosition.under,
        offset: const Offset(0, 8),
        color: Theme.of(context).cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.primaryEmerald.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 16,
              color: AppTheme.primaryEmerald,
            ),
            const SizedBox(width: 4),
            Text(
              state.selectedGovernorate.nameArabic,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryEmerald,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppTheme.primaryEmerald,
            ),
          ],
        ),
        onSelected: (Governorate gov) {
          context.read<PrayerBloc>().add(SelectGovernorate(gov));
        },
        itemBuilder: (context) {
          return state.governorates.map((gov) {
            final isSelected =
                gov.nameEnglish == state.selectedGovernorate.nameEnglish;
            return PopupMenuItem(
              value: gov,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    gov.nameArabic,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? AppTheme.primaryEmerald
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppTheme.primaryEmerald,
                    ),
                ],
              ),
            );
          }).toList();
        },
      ),
    );
  }
}
