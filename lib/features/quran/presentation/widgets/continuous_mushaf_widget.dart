import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/features/audio/presentation/bloc/audio_bloc.dart';
import 'package:ramadan_project/features/favorites/data/repositories/favorites_repository.dart';
import 'package:ramadan_project/features/favorites/domain/entities/favorite_ayah.dart';
import 'package:ramadan_project/features/khatmah/presentation/bloc/khatam_bloc.dart';
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:quran/quran.dart' as quran;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';

/// Continuous Mushaf-style page widget with RichText rendering
class ContinuousMushafPageWidget extends StatefulWidget {
  final int pageNumber;

  const ContinuousMushafPageWidget({super.key, required this.pageNumber});

  @override
  State<ContinuousMushafPageWidget> createState() =>
      _ContinuousMushafPageWidgetState();
}

class _ContinuousMushafPageWidgetState
    extends State<ContinuousMushafPageWidget> {
  late Future<QuranPage> _pageData;
  Ayah? _selectedAyah;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(ContinuousMushafPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNumber != widget.pageNumber) {
      _loadData();
      setState(() => _selectedAyah = null); // Clear selection on page change
    }
  }

  void _loadData() {
    _pageData = context.read<QuranRepository>().getPage(widget.pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuranPage>(
      future: _pageData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final page = snapshot.data!;

        return BlocBuilder<KhatamBloc, KhatamState>(
          builder: (context, khatamState) {
            bool isCompleted = false;
            bool isTarget = false;

            if (khatamState is KhatamLoaded && khatamState.plan != null) {
              isCompleted =
                  widget.pageNumber <= khatamState.plan!.currentProgressPage;
              isTarget =
                  widget.pageNumber >= khatamState.plan!.todayTargetStartPage &&
                  widget.pageNumber <= khatamState.plan!.todayTargetEndPage;
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFFF1F8E9) // Light green for completed
                    : const Color(0xFFFFFEF5), // Warm cream paper color
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: isTarget
                        ? AppTheme.accentGold.withOpacity(0.5)
                        : Colors.black26,
                    blurRadius: isTarget ? 16 : 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                // Islamic ornamental border
                border: Border.all(
                  width: isTarget ? 4 : 3,
                  color: isTarget
                      ? AppTheme.accentGold
                      : const Color(0xFFD4AF37), // Gold
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildHeader(page),
                    const SizedBox(height: 8),
                    Divider(
                      height: 1,
                      thickness: 2,
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildContinuousText(page),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      height: 1,
                      thickness: 2,
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                    ),
                    const SizedBox(height: 8),
                    _buildFooter(page, isCompleted),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(QuranPage page) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryEmerald.withOpacity(0.05),
            const Color(0xFFFAF7F0),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "سورة ${page.surahName}",
            style: const TextStyle(
              fontFamily: 'UthmanTaha',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryEmerald,
            ),
          ),
          Text(
            "الجزء ${page.juzNumber}",
            style: const TextStyle(
              fontFamily: 'UthmanTaha',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(QuranPage page, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFAF7F0),
            AppTheme.primaryEmerald.withOpacity(0.05),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isCompleted)
            const Icon(
              Icons.check_circle,
              color: AppTheme.primaryEmerald,
              size: 16,
            ),
          if (isCompleted) const SizedBox(width: 8),
          Text(
            "${page.pageNumber}",
            style: const TextStyle(
              fontFamily: 'UthmanTaha',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryEmerald,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinuousText(QuranPage page) {
    return RichText(
      text: TextSpan(
        children: page.ayahs.map((ayah) => _buildAyahSpan(ayah)).toList(),
        style: const TextStyle(
          fontFamily: 'UthmanTaha',
          fontSize: 22,
          height: 2.0,
          color: Colors.black87,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
    );
  }

  InlineSpan _buildAyahSpan(Ayah ayah) {
    final isSelected = _selectedAyah?.globalAyahNumber == ayah.globalAyahNumber;

    return TextSpan(
      children: [
        TextSpan(
          text: ayah.text,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryEmerald : Colors.black87,
            backgroundColor: isSelected
                ? AppTheme.primaryEmerald.withOpacity(0.1)
                : null,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              setState(() => _selectedAyah = ayah);
              _showActionBottomSheet(ayah);
            },
        ),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildAyahNumber(ayah.ayahNumber),
          ),
        ),
        const TextSpan(text: ' '), // Space between ayahs
      ],
    );
  }

  Widget _buildAyahNumber(int number) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFD4AF37),
      ),
      alignment: Alignment.center,
      child: Text(
        "$number",
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showActionBottomSheet(Ayah ayah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Ayah Text
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryEmerald.withOpacity(0.05),
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.primaryEmerald.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Text(
                  ayah.text,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'UthmanTaha',
                    fontSize: 22,
                    height: 1.8,
                    color: AppTheme.textDark,
                  ),
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.play_arrow_rounded,
                            label: 'تشغيل',
                            color: AppTheme.primaryEmerald,
                            onTap: () {
                              // Play audio using AudioBloc
                              context.read<AudioBloc>().add(
                                AudioPlayAyah(ayah.globalAyahNumber),
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FutureBuilder<bool>(
                            future: context
                                .read<FavoritesRepository>()
                                .isFavorite(ayah.globalAyahNumber),
                            builder: (context, snapshot) {
                              final isFavorite = snapshot.data ?? false;
                              return _buildActionButton(
                                icon: isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                label: isFavorite ? 'مفضلة' : 'إضافة',
                                color: AppTheme.accentGold,
                                onTap: () async {
                                  if (isFavorite) {
                                    await context
                                        .read<FavoritesRepository>()
                                        .removeFavorite(ayah.globalAyahNumber);
                                  } else {
                                    final favorite = FavoriteAyah(
                                      surahNumber: ayah.surahNumber,
                                      ayahNumber: ayah.ayahNumber,
                                      globalAyahNumber: ayah.globalAyahNumber,
                                      text: ayah.text,
                                      surahName: quran.getSurahNameArabic(
                                        ayah.surahNumber,
                                      ),
                                      addedAt: DateTime.now(),
                                    );
                                    await context
                                        .read<FavoritesRepository>()
                                        .addFavorite(favorite);
                                  }
                                  Navigator.pop(context);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isFavorite
                                              ? 'تم الحذف من المفضلة'
                                              : 'تمت الإضافة للمفضلة',
                                          style: GoogleFonts.cairo(),
                                        ),
                                        backgroundColor:
                                            AppTheme.primaryEmerald,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.copy_rounded,
                            label: 'نسخ',
                            color: AppTheme.primaryEmerald,
                            onTap: () {
                              // Copy
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.share_rounded,
                            label: 'مشاركة',
                            color: AppTheme.accentGold,
                            onTap: () {
                              // Share
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Tafsir Section
              Expanded(
                child: FutureBuilder<String>(
                  future: context.read<QuranRepository>().getTafsir(
                    ayah.surahNumber,
                    ayah.ayahNumber,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text("خطأ في تحميل التفسير: ${snapshot.error}"),
                      );
                    }
                    return SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "التفسير الميسر",
                            style: TextStyle(
                              fontFamily: 'UthmanTaha',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryEmerald,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            snapshot.data ?? "لا يوجد تفسير",
                            textAlign: TextAlign.justify,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(fontSize: 16, height: 1.8),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      setState(() => _selectedAyah = null);
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
