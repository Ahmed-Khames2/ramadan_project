import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/ramadan_worship/domain/entities/worship_task.dart';
import 'package:ramadan_project/features/ramadan_worship/presentation/cubit/worship_cubit.dart';
import 'package:ramadan_project/features/ramadan_worship/presentation/cubit/worship_state.dart';
import 'package:ramadan_project/features/ramadan_worship/presentation/widgets/worship_task_card.dart';
import 'package:ramadan_project/core/utils/string_extensions.dart';

class RamadanWorshipTrackerPage extends StatelessWidget {
  const RamadanWorshipTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('عباداتي في رمضان'),
        backgroundColor: AppTheme.primaryEmerald,
        centerTitle: true,
      ),
      body: BlocBuilder<WorshipCubit, WorshipState>(
        builder: (context, state) {
          if (state.status == WorshipStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == WorshipStatus.failure) {
            return Center(child: Text("حدث خطأ: ${state.errorMessage}"));
          }
          if (state.dayProgress == null) {
            return const Center(child: Text("جاري تحميل البيانات..."));
          }

          final progress = state.dayProgress!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, state),
                const SizedBox(height: 20),
                _buildSectionTitle(context, 'الصلوات الخمس'),
                ...progress.tasks
                    .where((t) => t.type == WorshipTaskType.prayer)
                    .map((t) => _buildTaskItem(context, t)),

                const SizedBox(height: 16),
                _buildSectionTitle(context, 'نوافل وقيام'),
                ...progress.tasks
                    .where(
                      (t) =>
                          t.type == WorshipTaskType.checkbox &&
                          ![
                            'morning_adhkar',
                            'evening_adhkar',
                            'dua',
                          ].contains(t.id),
                    )
                    .map((t) => _buildTaskItem(context, t)),

                const SizedBox(height: 16),
                _buildSectionTitle(context, 'الأذكار والدعاء'),
                ...progress.tasks
                    .where(
                      (t) => [
                        'morning_adhkar',
                        'evening_adhkar',
                        'dua',
                      ].contains(t.id),
                    )
                    .map((t) => _buildTaskItem(context, t)),

                const SizedBox(height: 16),
                _buildSectionTitle(context, 'أوراد يومية'),
                ...progress.tasks
                    .where((t) => t.type == WorshipTaskType.count)
                    .map((t) => _buildTaskItem(context, t)),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WorshipState state) {
    final completedCount =
        state.dayProgress?.tasks.where((t) => t.isCompleted).length ?? 0;
    final totalCount = state.dayProgress?.tasks.length ?? 1;
    final progressPercent = completedCount / totalCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryEmerald, AppTheme.darkEmerald],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "سلسلة الإنجاز",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: AppTheme.accentGold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${state.currentStreak.toArabic()} يوم",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              CircularProgressIndicator(
                value: progressPercent,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(AppTheme.accentGold),
                strokeWidth: 8,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.dayProgress?.isAllCompleted == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: AppTheme.accentGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "ما شاء الله! يوم مكتمل 🌙",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, WorshipTask task) {
    return WorshipTaskCard(
      task: task,
      onToggle: () {
        if (task.type != WorshipTaskType.count) {
          context.read<WorshipCubit>().toggleTask(task.id);
        }
      },
      onProgressUpdate: (newProgress) {
        context.read<WorshipCubit>().updateTaskProgress(task.id, newProgress);
      },
    );
  }
}
