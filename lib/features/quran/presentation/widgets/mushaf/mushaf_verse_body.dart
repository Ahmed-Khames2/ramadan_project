import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'ayah_symbol.dart';
import 'surah_header_widget.dart';
import 'basmala_widget.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/audio/presentation/bloc/audio_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:ramadan_project/features/favorites/presentation/bloc/favorites_bloc.dart';

class MushafVerseBody extends StatefulWidget {
  final QuranPage page;
  final double scale;
  final VoidCallback? onShowControls;

  const MushafVerseBody({
    super.key,
    required this.page,
    required this.scale,
    this.onShowControls,
  });

  @override
  State<MushafVerseBody> createState() => _MushafVerseBodyState();
}

class _MushafVerseBodyState extends State<MushafVerseBody> {
  @override
  void dispose() {
    super.dispose();
  }

  void _playAyah(Ayah ayah) {
    final globalId = ayah.globalAyahNumber;
    if (globalId <= 0) return;
    context.read<AudioBloc>().add(AudioPlayAyah(globalId));
  }

  void _autoPlayFrom(Ayah ayah) {
    final surah = ayah.surahNumber;
    final startAyah = ayah.ayahNumber;
    final endAyah = quran.getVerseCount(surah);

    final List<int> globalIds = [];
    for (int i = startAyah; i <= endAyah; i++) {
      // Calculate global ID. Note: quran package might have helpers or we do it manually.
      // We can use the logic from AudioBloc._onPlayPages or similar.
      int global = 0;
      for (int s = 1; s < surah; s++) {
        global += quran.getVerseCount(s);
      }
      global += i;
      globalIds.add(global);
    }

    if (globalIds.isNotEmpty) {
      context.read<AudioBloc>().add(AudioPlayRange(globalIds));
      Navigator.of(context).pop(); // Close bubble after starting
    }
  }

  void _showAyahDetails(Ayah ayah) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        // Show controls when Tafsir/Details dialog appears
        widget.onShowControls?.call();
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.primaryEmerald.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${ayah.surahName} (${ayah.ayahNumber})",
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.primaryEmerald,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    // Ayah Text
                    Text(
                      ayah.text,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'KFGQPCUthmanTahaNaskhRegular',
                        fontSize: 22,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Tafsir Section
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "التفسير الميسر:",
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primaryEmerald,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<String>(
                      future: context.read<QuranRepository>().getTafsir(
                        ayah.surahNumber,
                        ayah.ayahNumber,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        return Text(
                          snapshot.data ?? "لا يوجد تفسير متاح",
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            height: 1.6,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Action Buttons Row (Scrollable)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          // Play Single
                          _buildActionButton(
                            icon: Icons.play_arrow_rounded,
                            label: "تلاوة",
                            onTap: () {
                              _playAyah(ayah);
                              Navigator.pop(context);
                            },
                          ),
                          // Auto Play
                          _buildActionButton(
                            icon: Icons.playlist_play_rounded,
                            label: "تتابع",
                            onTap: () => _autoPlayFrom(ayah),
                          ),
                          // Favorite
                          BlocBuilder<FavoritesBloc, FavoritesState>(
                            builder: (context, state) {
                              final isFav =
                                  state is FavoritesLoaded &&
                                  state.favorites.contains(
                                    ayah.globalAyahNumber,
                                  );
                              return _buildActionButton(
                                icon: isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                iconColor: isFav ? Colors.red : null,
                                label: "المفضلة",
                                onTap: () {
                                  context.read<FavoritesBloc>().add(
                                    ToggleFavorite(ayah),
                                  );
                                },
                              );
                            },
                          ),
                          // Copy
                          _buildActionButton(
                            icon: Icons.copy_rounded,
                            label: "نسخ",
                            onTap: () async {
                              await Clipboard.setData(
                                ClipboardData(text: ayah.text),
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'تم نسخ الآية الكريمة',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontFamily: 'Cairo'),
                                    ),
                                    backgroundColor: AppTheme.primaryEmerald,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                          ),
                          // Share
                          _buildActionButton(
                            icon: Icons.share_rounded,
                            label: "مشاركة",
                            onTap: () {
                              Share.share(
                                "${ayah.text}\n\n[${ayah.surahName} - آية ${ayah.ayahNumber}]",
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryEmerald).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? AppTheme.primaryEmerald),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryEmerald,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Widget> surahWidgets = [];
    int? currentSurah;
    List<Ayah> surahAyahs = [];

    void flushSurah() {
      if (surahAyahs.isEmpty) return;

      final baseTextStyle =
          theme.textTheme.bodyLarge?.copyWith(
            fontFamily: 'KFGQPCUthmanTahaNaskhRegular',
            fontSize: (24 * widget.scale).clamp(20, 56),
            height: 1.9,
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontFamilyFallback: const ['UthmanTaha', 'Arial'],
          ) ??
          const TextStyle();

      final List<Widget> ayahWidgets = [];

      for (final ayah in surahAyahs) {
        ayahWidgets.add(
          BlocBuilder<AudioBloc, AudioState>(
            buildWhen: (previous, current) =>
                previous.currentAyah == ayah.globalAyahNumber ||
                current.currentAyah == ayah.globalAyahNumber,
            builder: (context, state) {
              final isPlayingItem = state.currentAyah == ayah.globalAyahNumber;

              return GestureDetector(
                onTap: () => _showAyahDetails(ayah),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isPlayingItem
                        ? AppTheme.accentGold.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: isPlayingItem
                        ? [
                            BoxShadow(
                              color: AppTheme.accentGold.withOpacity(0.25),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: AppTheme.accentGold.withOpacity(0.15),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: RichText(
                      textAlign: TextAlign.right,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${ayah.text.trim()}\u2060',
                            style: baseTextStyle,
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: AyahSymbol(
                              ayahNumber: ayah.ayahNumber,
                              scale: widget.scale,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }

      final surahNum = surahAyahs.first.surahNumber;
      final isNewSurah = surahAyahs.first.ayahNumber == 1;

      // Check if this page is the beginning of the Surah relative to the mushaf pages
      final firstPageOfSurah = quran.getPageNumber(surahNum, 1);
      final shouldShowBanner = widget.page.pageNumber == firstPageOfSurah;

      surahWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (shouldShowBanner) ...[
              const SizedBox(height: 16),
              SurahHeaderWidget(surahNumber: surahNum, scale: widget.scale),
            ],
            if (isNewSurah && surahNum != 1 && surahNum != 9)
              BasmalaWidget(scale: widget.scale),
            const SizedBox(height: 12),
            ...ayahWidgets.asMap().entries.map((entry) {
              final idx = entry.key;
              final widgetItem = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widgetItem,
                  if (idx < ayahWidgets.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(
                        color: AppTheme.accentGold.withValues(alpha: 0.2),
                        thickness: 0.5,
                        indent: 40,
                        endIndent: 40,
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      );
      surahAyahs = [];
    }

    for (final ayah in widget.page.ayahs) {
      if (currentSurah != null && currentSurah != ayah.surahNumber) {
        flushSurah();
      }
      currentSurah = ayah.surahNumber;
      surahAyahs.add(ayah);
    }
    flushSurah();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: surahWidgets,
        ),
      ),
    );
  }
}
