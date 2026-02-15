import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/azkar/presentation/bloc/azkar_bloc.dart';
import 'package:ramadan_project/features/azkar/data/models/azkar_model.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'azkar_details_page.dart';

class AzkarCategoriesPage extends StatelessWidget {
  const AzkarCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: BlocBuilder<AzkarBloc, AzkarState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryEmerald,
                        ),
                      );
                    }

                    if (state.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'حدث خطأ في تحميل الأذكار',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state.allAzkar.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد أذكار متوفرة حالياً',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      );
                    }

                    // Dynamic grouping based on JSON content
                    final categories = state.allAzkar
                        .map((e) => e.category)
                        .toSet()
                        .toList();
                    final Map<String, List<AzkarItem>> groupedAzkar = {};
                    for (var cat in categories) {
                      groupedAzkar[cat] = state.allAzkar
                          .where((e) => e.category == cat)
                          .toList();
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final items = groupedAzkar[category]!;
                        return _buildCategorySection(context, category, items);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textDark,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'الأذكار اليومية',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryEmerald,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    List<AzkarItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.accentGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _getCategoryDisplayName(category),
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildAzkarCard(context, item);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'صباح':
        return 'أذكار الصباح';
      case 'مساء':
        return 'أذكار المساء';
      case 'نوم':
        return 'أذكار النوم';
      case 'بعد الصلاة':
        return 'أذكار بعد الصلاة';
      default:
        return category;
    }
  }

  Widget _buildAzkarCard(BuildContext context, AzkarItem item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AzkarDetailsPage(azkarItem: item),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.accentGold.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryEmerald.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryEmerald.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: AppTheme.accentGold, size: 28),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryEmerald,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${item.azkarTexts.length} ذكراً',
              style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}
