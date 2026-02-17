import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart'; // For IslamicCard
import 'package:ramadan_project/features/quran/presentation/pages/enhanced_surah_index_page.dart';
import 'package:ramadan_project/features/azkar/presentation/pages/azkar_categories_page.dart';
import 'package:ramadan_project/features/khatmah/presentation/pages/khatmah_dashboard_page.dart';
import 'package:ramadan_project/features/azkar/presentation/pages/tasbih_page.dart';
import 'package:ramadan_project/features/prayer_times/presentation/pages/prayer_calendar_page.dart';

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
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EnhancedSurahIndexPage(),
                  ),
                ),
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
                    builder: (context) => const KhatmahDashboardPage(),
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
                colors: [Colors.white, widget.color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
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
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
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
