import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
                                return _buildHistoryItem(entry);
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.primaryEmerald,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سجل الختمات',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryEmerald,
                  height: 1.2,
                ),
              ),
              Text(
                'إنجازاتك السابقة الموثقة بالتواريخ',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppTheme.textGrey,
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
            style: GoogleFonts.cairo(fontSize: 18, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(dynamic entry) {
    final dateFormat = intl.DateFormat('yyyy/MM/dd', 'ar');

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تمت في ${dateFormat.format(entry.completionDate)}',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      Text(
                        'الإنجاز: خلال ${entry.totalDays} يوماً',
                        style: GoogleFonts.cairo(
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
