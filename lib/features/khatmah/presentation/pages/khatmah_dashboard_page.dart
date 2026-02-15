import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ramadan_project/features/khatmah/presentation/bloc/khatam_bloc.dart';
import 'package:ramadan_project/features/audio/presentation/bloc/audio_bloc.dart';
import 'package:ramadan_project/features/quran/presentation/pages/mushaf_page_view.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'khatmah_planner_page.dart';
import 'khatmah_history_page.dart';

class KhatmahDashboardPage extends StatelessWidget {
  const KhatmahDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmBeige,
      appBar: AppBar(title: const Text('متابعة الختمة')),
      body: BlocBuilder<KhatamBloc, KhatamState>(
        builder: (context, state) {
          if (state is KhatamLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is KhatamLoaded) {
            final plan = state.plan;
            final khatmahModel = state.khatmahPlan;

            if (khatmahModel == null) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<KhatamBloc>().add(LoadKhatamData());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTheme.spacing4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProgressCard(context, plan),
                    const SizedBox(height: AppTheme.spacing4),
                    _buildStatsGrid(context, plan),
                    const SizedBox(height: AppTheme.spacing4),
                    _buildTodayTargetCard(context, plan),
                    const SizedBox(height: AppTheme.spacing4),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('حدث خطأ ما'));
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 80,
            color: AppTheme.primaryEmerald.withOpacity(0.3),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            'لا توجد ختمة نشطة حالياً',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryEmerald,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            'ابدأ رحلتك مع القرآن الكريم اليوم',
            style: GoogleFonts.cairo(color: AppTheme.textGrey),
          ),
          const SizedBox(height: AppTheme.spacing6),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KhatmahPlannerPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('إنشاء خطة ختمة'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, dynamic plan) {
    final progress = plan?.progressPercentage ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing6),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التقدم الإجمالي',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${progress.toStringAsFixed(1)}%',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppTheme.primaryEmerald,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing4),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: AppTheme.primaryEmerald.withOpacity(0.1),
              color: AppTheme.primaryEmerald,
              minHeight: 12,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: AppTheme.spacing3),
            Text(
              plan?.statusMessage ?? '',
              style: GoogleFonts.cairo(color: AppTheme.textGrey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, dynamic plan) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'عدد الصفحات',
            '${plan?.currentProgressPage ?? 0}',
            Icons.pages,
          ),
        ),
        const SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: _buildStatItem(
            'معدل التقدم',
            plan?.isAhead == true ? 'سابق للجدول' : 'متأخر',
            plan?.isAhead == true ? Icons.trending_up : Icons.trending_down,
            color: plan?.isAhead == true ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          children: [
            Icon(icon, color: color ?? AppTheme.accentGold),
            const SizedBox(height: AppTheme.spacing2),
            Text(
              label,
              style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.textGrey),
            ),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color ?? AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTargetCard(BuildContext context, dynamic plan) {
    if (plan == null) return const SizedBox.shrink();

    return Card(
      color: AppTheme.primaryEmerald,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing6),
        child: Column(
          children: [
            Text(
              'ورد اليوم',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: AppTheme.spacing3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTargetBox('من صفحة', '${plan.todayTargetStartPage}'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.softGold,
                    size: 16,
                  ),
                ),
                _buildTargetBox('إلى صفحة', '${plan.todayTargetEndPage}'),
              ],
            ),
            const SizedBox(height: AppTheme.spacing6),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to Mushaf at the specific page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MushafPageView(
                            initialPage: plan.todayTargetStartPage,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chrome_reader_mode),
                    label: const Text('اقرأ الآن'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: AppTheme.darkEmerald,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing2),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AudioBloc>().add(
                        AudioPlayPages(
                          plan.todayTargetStartPage,
                          plan.todayTargetEndPage,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('بدأ تشغيل ورد اليوم...'),
                          backgroundColor: AppTheme.primaryEmerald,
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_circle_fill),
                    label: const Text('استمع للورد'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryEmerald,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetBox(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          context,
          'تعديل خطة الختمة',
          Icons.edit_calendar,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KhatmahPlannerPage()),
          ),
        ),
        const SizedBox(height: AppTheme.spacing2),
        _buildActionButton(context, 'سجل الختمات السابقة', Icons.history, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KhatmahHistoryPage()),
          );
        }),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppTheme.primaryEmerald),
      title: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      tileColor: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
