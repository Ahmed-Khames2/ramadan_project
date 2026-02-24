import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart'; // For IslamicCard
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/presentation/blocs/search_bloc.dart';
import 'package:ramadan_project/features/quran/presentation/pages/enhanced_surah_index_page.dart';
import 'package:ramadan_project/features/azkar/presentation/pages/azkar_categories_page.dart';
import 'package:ramadan_project/features/khatmah/presentation/pages/khatmah_dashboard_page.dart';
import 'package:ramadan_project/features/azkar/presentation/pages/tasbih_page.dart';
import 'package:ramadan_project/features/prayer_times/presentation/pages/prayer_calendar_page.dart';
import 'package:ramadan_project/features/qibla/presentation/pages/qibla_compass_page.dart';
import 'package:ramadan_project/features/40_hadith/presentation/pages/hadith_list_page.dart';
import 'package:ramadan_project/features/adhkar_virtues/presentation/pages/adhkar_virtue_list_page.dart';
import 'package:ramadan_project/features/hadith_library/presentation/pages/hadith_books_page.dart';

class AllWorshipsSection extends StatelessWidget {
  const AllWorshipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryEmerald.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  FontAwesomeIcons.kaaba,
                  size: 16,
                  color: AppTheme.primaryEmerald,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'جميع العبادات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              Container(
                height: 1,
                width: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryEmerald.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: AppTheme.spacing4,
            crossAxisSpacing: AppTheme.spacing4,
            childAspectRatio: 0.85,
            children: [
              _buildFeatureCard(
                context,
                title: 'القرآن الكريم',
                icon: FontAwesomeIcons.bookQuran,
                color: AppTheme.primaryEmerald,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnhancedSurahIndexPage(),
                    ),
                  );
                  if (context.mounted) {
                    context.read<SearchBloc>().add(ClearSearch());
                  }
                },
              ),
              _buildFeatureCard(
                context,
                title: 'أذكار المسلم',
                icon: FontAwesomeIcons.handsPraying,
                color: AppTheme.accentGold,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AzkarCategoriesPage(),
                  ),
                ),
              ),
              _buildFeatureCard(
                context,
                title: 'ختمة القرآن',
                icon: FontAwesomeIcons.listCheck,
                color: AppTheme.primaryEmerald,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const KhatmahDashboardPage(showBackButton: true),
                  ),
                ),
              ),
              _buildFeatureCard(
                context,
                title: 'المسبحة',
                icon: FontAwesomeIcons.stopwatch,
                color: AppTheme.accentGold,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TasbihPage()),
                ),
              ),
              _buildFeatureCard(
                context,
                title: 'التقويم',
                icon: FontAwesomeIcons.calendarDays,
                color: AppTheme.primaryEmerald,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarPage()),
                ),
              ),
              _buildFeatureCard(
                context,
                title: 'اتجاه القبلة',
                icon: FontAwesomeIcons.kaaba,
                color: AppTheme.accentGold,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QiblaCompassPage(),
                  ),
                ),
              ),
              _buildFeatureCard(
                context,
                title: 'الأربعين النووية',
                icon: FontAwesomeIcons.bookOpenReader,
                color: AppTheme.primaryEmerald,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HadithListPage(),
                  ),
                ),
              ),
              _buildFeatureCard(
                context,
                title: 'أفضال الأذكار',
                icon: FontAwesomeIcons.lightbulb,
                color: AppTheme.accentGold,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdhkarVirtueListPage(),
                  ),
                ),
              ),
              _buildFeatureCard(
                context,
                title: 'مكتبة الأحاديث',
                icon: FontAwesomeIcons.bookOpen,
                color: AppTheme.primaryEmerald,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HadithBooksPage(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
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

  void _onTapDown(TapDownDetails details) => setState(() => _scale = 0.95);
  void _onTapUp(TapUpDetails details) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

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
            padding: const EdgeInsets.all(AppTheme.spacing3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).cardColor,
                  widget.color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, size: 24, color: widget.color),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.2,
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
