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
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class MushafVerseBody extends StatefulWidget {
  final QuranPage page;
  final double scale;
  final int? initialSurah;
  final int? initialAyah;
  final VoidCallback? onShowControls;

  const MushafVerseBody({
    super.key,
    required this.page,
    this.scale = 1.0,
    this.initialSurah,
    this.initialAyah,
    this.onShowControls,
  });

  @override
  State<MushafVerseBody> createState() => _MushafVerseBodyState();
}

class _MushafVerseBodyState extends State<MushafVerseBody> {
  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _ayahKey = GlobalKey();
  final GlobalKey _tutorialKey = GlobalKey();
  final ScreenshotController _screenshotController = ScreenshotController();
  List<TargetFocus> targets = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialSurah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final targetKey = (widget.initialAyah != null) ? _ayahKey : _headerKey;
        if (targetKey.currentContext != null) {
          Scrollable.ensureVisible(
            targetKey.currentContext!,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });
    }
    _checkAndShowTutorial();
  }

  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final bool shown = prefs.getBool('ayah_details_tutorial_shown') ?? false;

    if (!shown) {
      // Delay to allow widgets to render
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;

        // Ensure the tutorial target is visible
        if (_tutorialKey.currentContext != null) {
          Scrollable.ensureVisible(
            _tutorialKey.currentContext!,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }

        _initTutorialTargets();
        _showTutorial();
      });
    }
  }

  void _initTutorialTargets() {
    targets.clear();
    targets.add(
      TargetFocus(
        identify: "ayah_details_tutorial",
        keyTarget: _tutorialKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.touch_app_rounded,
                    color: AppTheme.accentGold,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "اضغط ضغطة مطولة على الآية לרؤية التفسير والمشاركة",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => controller.next(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: AppTheme.primaryEmerald,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "فهمت",
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 12,
      ),
    );

    // Step 2: Scroll Down Tutorial
    targets.add(
      TargetFocus(
        identify: "scroll_down_tutorial",
        keyTarget:
            _headerKey, // Pointing generally to the top area or just use a full screen overlay if possible
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.keyboard_double_arrow_down_rounded,
                    color: AppTheme.accentGold,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "اسحب للأسفل لتكملة القراءة",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => controller.next(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: AppTheme.primaryEmerald,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "ابدأ القراءة",
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
      ),
    );
  }

  void _showTutorial() {
    TutorialCoachMark(
      targets: targets,
      colorShadow: AppTheme.primaryEmerald,
      textSkip: "تخطي",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        _markTutorialAsShown();
      },
      onSkip: () {
        _markTutorialAsShown();
        return true;
      },
    ).show(context: context);
  }

  Future<void> _markTutorialAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ayah_details_tutorial_shown', true);
  }

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

  Future<void> _shareAyahAsImage(Ayah ayah) async {
    // Generate the image from a separate widget to have full control over the look
    final image = await _screenshotController.captureFromWidget(
      Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryEmerald,
              AppTheme.primaryEmerald.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative Header
            Icon(
              Icons.format_quote_rounded,
              color: AppTheme.accentGold,
              size: 40,
            ),
            const SizedBox(height: 20),
            // Ayah Text
            Text(
              ayah.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'KFGQPCUthmanTahaNaskhRegular',
                fontSize: 28,
                height: 1.8,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            // Divider
            Container(
              width: 100,
              height: 2,
              color: AppTheme.accentGold.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            // Reference
            Text(
              "سورة ${ayah.surahName} - آية ${ayah.ayahNumber}",
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentGold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "تطبيق زاد المؤمن",
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
      delay: const Duration(milliseconds: 100),
    );

    final directory = await getTemporaryDirectory();
    final imagePath = await File(
      '${directory.path}/ayah_${ayah.globalAyahNumber}.png',
    ).create();
    await imagePath.writeAsBytes(image);

    await Share.shareXFiles(
      [XFile(imagePath.path)],
      text: "قال تعالى: ${ayah.text} [${ayah.surahName} - ${ayah.ayahNumber}]",
    );
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
                      _truncateAyah(ayah.text),
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
                    Stack(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              // Play Ayah
                              _buildActionButton(
                                icon: Icons.play_arrow_rounded,
                                label: "تشغيل",
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
                                      state.favorites.any(
                                        (f) =>
                                            f.globalAyahNumber ==
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
                              // Image Share
                              _buildActionButton(
                                icon: Icons.image_rounded,
                                label: "صورة",
                                onTap: () {
                                  Navigator.pop(context);
                                  _shareAyahAsImage(ayah);
                                },
                              ),
                              // Share Text
                              _buildActionButton(
                                icon: Icons.share_rounded,
                                label: "نص",
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
                        // Scroll Indicator for the horizontal row
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: _HorizontalScrollHint(),
                        ),
                      ],
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
                onLongPress: () => _showAyahDetails(ayah),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  key:
                      ayah.globalAyahNumber ==
                          widget.page.ayahs.first.globalAyahNumber
                      ? _tutorialKey
                      : null,
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
              SurahHeaderWidget(
                key:
                    widget.initialSurah == surahNum &&
                        widget.initialAyah == null
                    ? _headerKey
                    : null,
                surahNumber: surahNum,
                scale: widget.scale,
              ),
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

  String _truncateAyah(String text) {
    final words = text.split(' ');
    if (words.length <= 5) return text;
    return '${words.take(5).join(' ')}...';
  }
}

class _HorizontalScrollHint extends StatefulWidget {
  @override
  State<_HorizontalScrollHint> createState() => _HorizontalScrollHintState();
}

class _HorizontalScrollHintState extends State<_HorizontalScrollHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Theme.of(context).cardColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: const Icon(
          Icons.chevron_left_rounded,
          color: AppTheme.accentGold,
          size: 24,
        ),
      ),
    );
  }
}
