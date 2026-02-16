import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ramadan_project/features/prayer_times/presentation/bloc/prayer_bloc.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:ramadan_project/features/prayer_times/presentation/widgets/prayer_widgets.dart';

import 'package:ramadan_project/features/quran/presentation/pages/surah_index_page.dart';

import 'package:ramadan_project/features/khatmah/presentation/pages/khatmah_dashboard_page.dart';
import 'package:ramadan_project/features/azkar/presentation/pages/tasbih_page.dart';
import 'package:ramadan_project/features/prayer_times/presentation/pages/prayer_calendar_page.dart';
import 'package:ramadan_project/features/azkar/presentation/pages/azkar_categories_page.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;

              return BlocBuilder<PrayerBloc, PrayerState>(
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
                    return Center(child: Text(prayerState.message));
                  }

                  if (prayerState is PrayerLoaded) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const PrayerHeader(),
                          const SizedBox(height: AppTheme.spacing4),

                          if (isWide)
                            _buildWideLayout(context, prayerState)
                          else
                            _buildNarrowLayout(context, prayerState),

                          const SizedBox(height: AppTheme.spacing6),
                          _buildQuickActions(context),
                          const SizedBox(height: AppTheme.spacing8),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, PrayerLoaded state) {
    return Column(
      children: [
        CurrentPrayerCard(prayers: state.prayerTimes),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing6),
          child: Column(
            children: state.prayerTimes.map((prayer) {
              return PrayerTimeRow(prayer: prayer, isCurrent: prayer.isCurrent);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context, PrayerLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: CurrentPrayerCard(prayers: state.prayerTimes),
          ),
          const SizedBox(width: AppTheme.spacing4),
          Expanded(
            flex: 3,
            child: Column(
              children: state.prayerTimes.map((prayer) {
                return PrayerTimeRow(
                  prayer: prayer,
                  isCurrent: prayer.isCurrent,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الوصول السريع',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: AppTheme.spacing4,
            crossAxisSpacing: AppTheme.spacing4,
            childAspectRatio: 0.82,
            children: [
              _buildActionCard(
                context,
                title: 'القرآن',
                icon: Icons.menu_book_rounded,
                color: AppTheme.primaryEmerald,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SurahIndexPage(),
                  ),
                ),
              ),
              _buildActionCard(
                context,
                title: 'الأذكار',
                icon: FontAwesomeIcons.handsPraying,
                color: AppTheme.accentGold,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AzkarCategoriesPage(),
                  ),
                ),
              ),
              _buildActionCard(
                context,
                title: 'الختمة',
                icon: Icons.auto_awesome_outlined,
                color: AppTheme.primaryEmerald,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KhatmahDashboardPage(),
                  ),
                ),
              ),
              _buildActionCard(
                context,
                title: 'المسبحة',
                icon: Icons.radio_button_checked_rounded,
                color: AppTheme.accentGold,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TasbihPage()),
                ),
              ),
              _buildActionCard(
                context,
                title: 'التقويم',
                icon: Icons.calendar_month_rounded,
                color: AppTheme.primaryEmerald,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarPage()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _ScaleActionCard(
      title: title,
      icon: icon,
      color: color,
      onTap: onTap,
    );
  }
}

class _ScaleActionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ScaleActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ScaleActionCard> createState() => _ScaleActionCardState();
}

class _ScaleActionCardState extends State<_ScaleActionCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: IslamicCard(
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.spacing4,
              horizontal: AppTheme.spacing2,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 32, color: widget.color),
                const SizedBox(height: AppTheme.spacing3),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
