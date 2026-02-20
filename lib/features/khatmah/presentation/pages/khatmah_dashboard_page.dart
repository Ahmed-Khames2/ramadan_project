import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ramadan_project/features/khatmah/presentation/bloc/khatam_bloc.dart';
import 'package:ramadan_project/features/quran/presentation/pages/mushaf_page_view.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/khatmah/domain/entities/khatmah_entities.dart';
import 'package:ramadan_project/features/khatmah/domain/entities/khatam_plan.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'khatmah_planner_page.dart';
import 'khatmah_history_page.dart';

class KhatmahDashboardPage extends StatefulWidget {
  final bool showBackButton;

  const KhatmahDashboardPage({super.key, this.showBackButton = false});

  @override
  State<KhatmahDashboardPage> createState() => _KhatmahDashboardPageState();
}

class _KhatmahDashboardPageState extends State<KhatmahDashboardPage> {
  bool _hasAgreedToReadAhead = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: BlocBuilder<KhatamBloc, KhatamState>(
            builder: (context, state) {
              if (state is KhatamLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryEmerald,
                  ),
                );
              }

              if (state is KhatamLoaded) {
                final plan = state.plan;
                final khatmahModel = state.khatmahPlan;

                if (khatmahModel == null) {
                  return Column(
                    children: [
                      _buildHeader(context),
                      Expanded(child: _buildEmptyState(context)),
                    ],
                  );
                }

                return Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context.read<KhatamBloc>().add(LoadKhatamData());
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing4,
                            vertical: AppTheme.spacing2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (plan != null) ...[
                                _buildProgressHeader(context, plan),
                                const SizedBox(height: AppTheme.spacing4),
                                _buildStatsGrid(context, plan),
                                const SizedBox(height: AppTheme.spacing4),
                                _buildTodayTargetCard(
                                  context,
                                  plan,
                                  khatmahModel,
                                ),
                              ],
                              const SizedBox(height: AppTheme.spacing4),
                              _buildActionButtons(context, khatmahModel),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _buildHeader(context),
                  const Expanded(child: Center(child: Text('حدث خطأ ما'))),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          if (widget.showBackButton) ...[
            const IslamicBackButton(),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: widget.showBackButton
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Text(
                  'متابعة الختمة',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryEmerald,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'نظم خطتك اليومية لختم القرآن الكريم',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories,
            size: 100,
            color: AppTheme.primaryEmerald.withValues(alpha: 0.2),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            'ابدأ مشروع ختمة جديد',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryEmerald,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            'نظم قراءتك للقرآن الكريم في رمضان',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
              elevation: 4,
              shadowColor: AppTheme.primaryEmerald.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'إنشاء خطة الآن',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, KhatamPlan plan) {
    final progress = plan.progressPercentage;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing6),
      decoration: BoxDecoration(
        color: AppTheme.primaryEmerald.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الإنجاز العام',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.statusMessage,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primaryEmerald,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${progress.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppTheme.primaryEmerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing6),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryEmerald,
                        AppTheme.primaryEmerald.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, KhatamPlan plan) {
    final bool isAhead = plan.isAhead;
    final int diff = plan.pagesDifference;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            'الصفحات المقروءة',
            '${plan.currentProgressPage}',
            Icons.menu_book_rounded,
            AppTheme.primaryEmerald,
          ),
        ),
        const SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: _buildStatItem(
            context,
            (plan.remainingTodayPages) == 0 ? 'حالة التميز' : 'المتبقي اليوم',
            (plan.remainingTodayPages) == 0
                ? (isAhead ? 'سابق للجدول' : 'ماشي عالمسطرة')
                : '${plan.remainingTodayPages} صفحة',
            (plan.remainingTodayPages) == 0
                ? Icons.stars_rounded
                : Icons.hourglass_top_rounded,
            (plan.remainingTodayPages) == 0
                ? Colors.green.shade700
                : AppTheme.accentGold,
            subtitle: (plan.remainingTodayPages) == 0 && diff > 0
                ? '+$diff صفحة مسبقة'
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.02,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color.withValues(alpha: 0.5), size: 18),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.1,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTodayTargetCard(
    BuildContext context,
    KhatamPlan plan,
    KhatmahPlan? khatmahModel,
  ) {
    if (khatmahModel == null) return const SizedBox.shrink();

    final bool isDoneToday = plan.remainingTodayPages == 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing6),
          decoration: BoxDecoration(
            color: (isDoneToday ? AppTheme.primaryEmerald : AppTheme.accentGold)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color:
                  (isDoneToday ? AppTheme.primaryEmerald : AppTheme.accentGold)
                      .withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDoneToday
                        ? Icons.task_alt_rounded
                        : Icons.menu_book_rounded,
                    color: isDoneToday
                        ? AppTheme.primaryEmerald
                        : AppTheme.darkEmerald,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isDoneToday
                        ? 'الورد القادم (ما تم إنجازه مسبقاً)'
                        : 'ورد اليوم',
                    style: TextStyle(
                      color: isDoneToday
                          ? AppTheme.primaryEmerald
                          : AppTheme.darkEmerald,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTargetBox(
                    context,
                    'بدءاً من',
                    '${plan.dailyTargetStartPage}',
                    isDoneToday,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    height: 40,
                    width: 2,
                    color:
                        (isDoneToday
                                ? AppTheme.primaryEmerald
                                : AppTheme.accentGold)
                            .withValues(alpha: 0.3),
                  ),
                  _buildTargetBox(
                    context,
                    'وصولاً إلى',
                    '${plan.dailyTargetEndPage}',
                    isDoneToday,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing6),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isDoneToday) {
                      if (_hasAgreedToReadAhead) {
                        _navigateToMushaf(
                          context,
                          khatmahModel.currentProgressPage + 1,
                        );
                      } else {
                        _showReadAheadDialog(
                          context,
                          khatmahModel.currentProgressPage + 1,
                        );
                      }
                    } else {
                      _navigateToMushaf(
                        context,
                        khatmahModel.currentProgressPage + 1,
                      );
                    }
                  },
                  icon: Icon(
                    isDoneToday
                        ? Icons.rocket_launch_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    isDoneToday
                        ? 'استمر في القراءة المسبقة'
                        : 'ابدأ القراءة الآن',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDoneToday
                        ? AppTheme.primaryEmerald
                        : AppTheme.darkEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetBox(
    BuildContext context,
    String label,
    String value,
    bool isHighlight,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? AppTheme.primaryEmerald : AppTheme.darkEmerald,
            fontWeight: FontWeight.w900,
            fontSize: 32,
          ),
        ),
        Text(
          'صفحة',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, KhatmahPlan? khatmahModel) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.03,
            ),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPremiumActionButton(
            context,
            'سجل الإنجازات',
            'راجع رحلتك في ختم القرآن',
            Icons.history_edu_rounded,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KhatmahHistoryPage()),
            ),
          ),
          const Divider(height: 1),
          _buildPremiumActionButton(
            context,
            'حذف الختمة الحالية',
            'سيتم مسح جميع بيانات هذه الختمة',
            Icons.delete_sweep_rounded,
            () => _showDeleteConfirmation(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الختمة'),
        content: const Text(
          'هل أنت متأكد من حذف الختمة الحالية؟ لا يمكن تراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<KhatamBloc>().add(DeleteKhatmahPlan());
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : AppTheme.primaryEmerald;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDestructive
                          ? Colors.red
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: isDestructive
                  ? Colors.red.withOpacity(0.5)
                  : AppTheme.textGrey,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMushaf(BuildContext context, int startPage) {
    final khatamBloc = context.read<KhatamBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MushafPageView(
          initialPage: startPage,
          shouldSaveProgress: false,
          onPageChanged: (page) {
            khatamBloc.add(UpdateKhatmahProgress(page));
          },
        ),
      ),
    );
  }

  void _showReadAheadDialog(BuildContext context, int startPage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.rocket_launch_rounded, color: AppTheme.primaryEmerald),
            const SizedBox(width: 12),
            Text('أنت رائع!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'لقد أتممت ورد اليوم بنجاح، هل تريد البدء في ورد الغد مسبقاً؟ البرنامج هيفضل يسجل تقدمك تلقائياً.',
          style: TextStyle(),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('لاحقاً', style: TextStyle(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasAgreedToReadAhead = true;
              });
              Navigator.pop(context);
              _navigateToMushaf(context, startPage);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryEmerald,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('نعم، استمر', style: TextStyle()),
          ),
        ],
      ),
    );
  }
}
