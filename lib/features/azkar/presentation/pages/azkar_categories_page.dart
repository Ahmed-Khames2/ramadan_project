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
      extendBodyBehindAppBar: true,
      body: DecorativeBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'الأذكار اليومية',
                      style: GoogleFonts.cairo(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryEmerald,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'أذكار المسلم وطمأنينة القلب',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppTheme.textGrey,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
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
                      return _buildErrorState();
                    }

                    if (state.allAzkar.isEmpty) {
                      return _buildEmptyState();
                    }

                    // Filter featured Azkar
                    final morningAzkar = state.allAzkar.firstWhere(
                      (e) => e.category == 'صباح',
                      orElse: () => state.allAzkar.first,
                    );
                    final eveningAzkar = state.allAzkar.firstWhere(
                      (e) => e.category == 'مساء',
                      orElse: () => state.allAzkar.first,
                    );

                    // Other categories
                    final otherCategories = state.allAzkar
                        .map((e) => e.category)
                        .where((c) => c != 'صباح' && c != 'مساء')
                        .toSet()
                        .toList();

                    final Map<String, List<AzkarItem>> groupedAzkar = {};
                    for (var cat in otherCategories) {
                      groupedAzkar[cat] = state.allAzkar
                          .where((e) => e.category == cat)
                          .toList();
                    }

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      children: [
                        _buildFeaturedSection(
                          context,
                          morningAzkar,
                          eveningAzkar,
                        ),
                        const SizedBox(height: 24),
                        if (otherCategories.isNotEmpty) ...[
                          const OrnamentalDivider(),
                          const SizedBox(height: 24),
                          ...otherCategories.map((category) {
                            final items = groupedAzkar[category]!;
                            // For other categories, we might have multiple items per category,
                            // or just one. The user wants "same idea as morning/evening".
                            // If a category has multiple items, we render them as a list of cards.
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: _buildPremiumCard(context, item),
                                );
                              }).toList(),
                            );
                          }),
                        ],
                      ],
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

  // Removed _buildHeader as it's now in AppBar

  Widget _buildFeaturedSection(
    BuildContext context,
    AzkarItem morning,
    AzkarItem evening,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildFeaturedCard(context, morning, 'أذكار الصباح', const [
            Color(0xFFFFF9C4),
            Color(0xFFFFB300),
          ], Icons.wb_sunny_rounded),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildFeaturedCard(context, evening, 'أذكار المساء', const [
            Color(0xFFE1F5FE),
            Color(0xFF0277BD),
          ], Icons.nightlight_round),
        ),
      ],
    );
  }

  Widget _buildPremiumCard(BuildContext context, AzkarItem item) {
    // Use a consistent, unified color palette based on AppTheme
    // We can use the category to slightly vary the shade or keep it uniform
    final List<Color> colors = [
      AppTheme.surfaceWhite,
      const Color(0xFFF1F8E9), // Very light Green
    ];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AzkarDetailsPage(azkarItem: item),
          ),
        );
      },
      child: Container(
        height: 110, // Reduced height for better list density
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryEmerald.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppTheme.primaryEmerald.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Background Pattern/Icon
            Positioned(
              left: -10,
              bottom: -10,
              child: Icon(
                item.icon,
                size: 80,
                color: AppTheme.primaryEmerald.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryEmerald.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: AppTheme.primaryEmerald,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${item.azkarTexts.length} ذكراً',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: AppTheme.primaryEmerald,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppTheme.textGrey.withOpacity(0.3),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed _getGradientColors as it's no longer needed

  Widget _buildFeaturedCard(
    BuildContext context,
    AzkarItem item,
    String title,
    List<Color> gradientColors,
    IconData icon, {
    double height = 180,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AzkarDetailsPage(azkarItem: item),
          ),
        );
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[1].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
        ),
        child: Stack(
          children: [
            // Background Icon
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                icon,
                size: height * 0.6,
                color: AppTheme.primaryEmerald.withOpacity(0.1),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: AppTheme.primaryEmerald,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.format_list_bulleted_rounded,
                              size: 14,
                              color: AppTheme.textGrey.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.azkarTexts.length} ذكراً',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: AppTheme.textGrey.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Optional: Play/Go icon on the left (since RTL)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppTheme.primaryEmerald,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ في تحميل الأذكار',
            style: GoogleFonts.cairo(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'لا توجد أذكار متوفرة حالياً',
        style: GoogleFonts.cairo(fontSize: 18),
      ),
    );
  }
}
