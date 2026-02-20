import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart' as intl;
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/khatmah/presentation/bloc/khatam_bloc.dart';

import 'package:ramadan_project/core/widgets/common_widgets.dart';

class KhatmahHistoryPage extends StatelessWidget {
  const KhatmahHistoryPage({super.key});

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
                final history = context
                    .read<KhatamBloc>()
                    .khatmahRepository
                    .getKhatmahHistory();

                return Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: history.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing4,
                                vertical: AppTheme.spacing2,
                              ),
                              itemCount: history.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppTheme.spacing3),
                              itemBuilder: (context, index) {
                                final entry = history[index];
                                return _buildHistoryItem(context, entry);
                              },
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
          const IslamicBackButton(),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سجل الختمات',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryEmerald,
                  height: 1.2,
                ),
              ),
              Text(
                'إنجازاتك السابقة الموثقة بالتواريخ',
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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppTheme.primaryEmerald.withOpacity(0.1),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            'لا يوجد سجل ختمات حتى الآن',
            style: TextStyle(fontSize: 18, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, dynamic entry) {
    final dateFormat = intl.DateFormat('yyyy/MM/dd', 'ar');

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
        border: Border.all(
          color: AppTheme.primaryEmerald.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Share completion or view details
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: AppTheme.accentGold,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تمت في ${dateFormat.format(entry.completionDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        'الإنجاز: خلال ${entry.totalDays} يوماً',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryEmerald,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.share_rounded,
                  size: 22,
                  color: AppTheme.primaryEmerald,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
