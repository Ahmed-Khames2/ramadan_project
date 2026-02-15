import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/khatmah/presentation/bloc/khatam_bloc.dart';

class KhatmahHistoryPage extends StatelessWidget {
  const KhatmahHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmBeige,
      appBar: AppBar(title: const Text('سجل الختمات')),
      body: BlocBuilder<KhatamBloc, KhatamState>(
        builder: (context, state) {
          if (state is KhatamLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is KhatamLoaded) {
            final history = context
                .read<KhatamBloc>()
                .khatmahRepository
                .getKhatmahHistory();

            if (history.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              itemCount: history.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppTheme.spacing3),
              itemBuilder: (context, index) {
                final entry = history[index];
                return _buildHistoryItem(entry);
              },
            );
          }

          return const Center(child: Text('حدث خطأ ما'));
        },
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

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified, color: AppTheme.accentGold),
        ),
        title: Text(
          entry.title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'تمت في ${dateFormat.format(entry.completionDate)} (خلال ${entry.totalDays} يوماً)',
          style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.textGrey),
        ),
        trailing: const Icon(
          Icons.share,
          size: 20,
          color: AppTheme.primaryEmerald,
        ),
        onTap: () {
          // Share completion or view details
        },
      ),
    );
  }
}
