import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/features/prayer_times/presentation/bloc/prayer_bloc.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:ramadan_project/features/home/presentation/widgets/custom_home_header.dart';
import 'package:ramadan_project/features/home/presentation/widgets/horizontal_prayer_strip.dart';
import 'package:ramadan_project/features/home/presentation/widgets/accurate_prayer_countdown.dart';
import 'package:ramadan_project/features/home/presentation/widgets/all_worships_section.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecorativeBackground(
        child: SafeArea(
          child: BlocBuilder<PrayerBloc, PrayerState>(
            builder: (context, prayerState) {
              if (prayerState is PrayerLoading ||
                  prayerState is PrayerInitial) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryEmerald,
                  ),
                );
              }

              if (prayerState is PrayerError) {
                return Center(
                  child: Text(
                    prayerState.message,
                    style: const TextStyle(color: AppTheme.textDark),
                  ),
                );
              }

              if (prayerState is PrayerLoaded) {
                return Column(
                  children: [
                    // Sticky Header with background to ensure premium look when scrolling
                    Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.only(top: AppTheme.spacing4),
                      child: const CustomHomeHeader(),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacing2,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: AppTheme.spacing4),

                            // Accurate Prayer Countdown
                            AccuratePrayerCountdown(
                              prayers: prayerState.prayerTimes,
                            ),

                            const SizedBox(height: AppTheme.spacing6),

                            // Horizontal Prayer Strip
                            const HorizontalPrayerStrip(),

                            const SizedBox(height: AppTheme.spacing8),

                            // All Worships Section
                            const OrnamentalDivider(),
                            const SizedBox(height: AppTheme.spacing4),
                            const AllWorshipsSection(),

                            const SizedBox(
                              height: 110,
                            ), // Padding for floating navbar
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
