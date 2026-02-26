import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'package:ramadan_project/features/quran/presentation/bloc/quran_settings_cubit.dart';
import 'ayah_symbol.dart';
import 'surah_header_widget.dart';
import 'basmala_widget.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/audio/presentation/bloc/audio_bloc.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';

class MushafVerseBody extends StatefulWidget {
  final QuranPage page;
  final double scale;
  final int? initialSurah;
  final int? initialAyah;
  final VoidCallback? onShowControls;
  final Color? textColor;
  final Function(Ayah)? onAyahTap;
  final MushafReadingMode readingMode;

  const MushafVerseBody({
    super.key,
    required this.page,
    this.scale = 1.0,
    this.initialSurah,
    this.initialAyah,
    this.onShowControls,
    this.textColor,
    this.onAyahTap,
    required this.readingMode,
    this.selectedAyahId,
  });

  final int? selectedAyahId;

  @override
  State<MushafVerseBody> createState() => _MushafVerseBodyState();
}

class _MushafVerseBodyState extends State<MushafVerseBody> {
  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _tutorialKey = GlobalKey();
  final GlobalKey _centerKey = GlobalKey();
  final Map<int, GlobalKey> _ayahKeyMap = {}; // Map globalAyahNumber to key
  final ScreenshotController _screenshotController = ScreenshotController();
  List<TargetFocus> targets = [];

  @override
  void initState() {
    super.initState();
    // Pre-populate keys for all ayahs on the page to ensure they are available for scrolling
    for (final ayah in widget.page.ayahs) {
      final isFirstAyah =
          ayah.globalAyahNumber == widget.page.ayahs.first.globalAyahNumber;
      _ayahKeyMap[ayah.globalAyahNumber] = isFirstAyah
          ? _tutorialKey
          : GlobalKey();
    }

    if (widget.initialSurah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        GlobalKey? targetKey;

        // Priority 1: Current playing ayah if it's on this page
        final audioState = context.read<AudioBloc>().state;
        bool isFirstElement = false;

        if (audioState.currentAyah != null &&
            _ayahKeyMap.containsKey(audioState.currentAyah)) {
          targetKey = _ayahKeyMap[audioState.currentAyah];
          isFirstElement =
              audioState.currentAyah ==
              widget.page.ayahs.first.globalAyahNumber;
        }
        // Priority 2: Initial ayah/surah from navigation
        else if (widget.initialAyah != null && widget.initialSurah != null) {
          final globalId = _getGlobalId(
            widget.initialSurah!,
            widget.initialAyah!,
          );
          targetKey = _ayahKeyMap[globalId];
          isFirstElement = globalId == widget.page.ayahs.first.globalAyahNumber;
        }
        // Priority 3: Surah header
        else if (widget.initialSurah != null) {
          targetKey = _headerKey;
          isFirstElement = true; // Header is always at the top
        }

        if (targetKey != null && targetKey.currentContext != null) {
          if (isFirstElement) {
            Scrollable.of(targetKey.currentContext!).position.animateTo(
              0.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            );
          } else {
            Scrollable.ensureVisible(
              targetKey.currentContext!,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              alignment: 0.5, // Center on screen
            );
          }
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
        keyTarget: _centerKey,
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
                  Icon(
                    Icons.touch_app_rounded,
                    color: widget.readingMode == MushafReadingMode.navy
                        ? Colors.white
                        : AppTheme.accentGold,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "اضغط ضغطة مطولة على أي آية لعرض التفسير والمشاركة",
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
        keyTarget: _centerKey,
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
                  Icon(
                    Icons.keyboard_double_arrow_down_rounded,
                    color: widget.readingMode == MushafReadingMode.navy
                        ? Colors.white
                        : AppTheme.accentGold,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Widget> surahWidgets = [];
    int? currentSurah;
    List<Ayah> surahAyahs = [];

    void flushSurah() {
      if (surahAyahs.isEmpty) return;

      final resolvedTextColor = widget.textColor ?? theme.colorScheme.onSurface;

      final baseTextStyle =
          theme.textTheme.bodyLarge?.copyWith(
            fontFamily: 'KFGQPCUthmanTahaNaskhRegular',
            fontSize: (24 * widget.scale).clamp(20, 56),
            height: 1.85,
            color: resolvedTextColor,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
            fontFamilyFallback: const ['UthmanTaha', 'Amiri', 'Cairo'],
          ) ??
          TextStyle(color: resolvedTextColor);

      // Build one continuous RichText for the whole surah block on this page
      final List<Widget> ayahWidgets = [];

      for (final ayah in surahAyahs) {
        final isFirstAyah =
            ayah.globalAyahNumber == widget.page.ayahs.first.globalAyahNumber;

        final ayahKey = _ayahKeyMap[ayah.globalAyahNumber]!;

        // Clean text to avoid strange glyph rendering issues
        final cleanedText = _cleanQuranText(ayah.text);

        ayahWidgets.add(
          BlocBuilder<AudioBloc, AudioState>(
            buildWhen: (previous, current) =>
                previous.currentAyah == ayah.globalAyahNumber ||
                current.currentAyah == ayah.globalAyahNumber,
            builder: (context, state) {
              final isPlayingItem = state.currentAyah == ayah.globalAyahNumber;

              return GestureDetector(
                key: isFirstAyah ? _tutorialKey : ayahKey,
                onLongPress: () => widget.onAyahTap?.call(ayah),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  // No padding/margin between ayahs — continuous flow
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isPlayingItem ||
                            widget.selectedAyahId == ayah.globalAyahNumber)
                        ? (widget.readingMode == MushafReadingMode.navy
                                  ? const Color(0xFF35355F)
                                  : isPlayingItem
                                  ? AppTheme.accentGold
                                  : AppTheme.primaryEmerald)
                              .withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: widget.selectedAyahId == ayah.globalAyahNumber
                        ? Border.all(
                            color:
                                (widget.readingMode == MushafReadingMode.navy
                                        ? Colors.white
                                        : AppTheme.primaryEmerald)
                                    .withValues(alpha: 0.1),
                            width: 1,
                          )
                        : null,
                  ),
                  child: RichText(
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: cleanedText,
                          style: baseTextStyle.copyWith(
                            backgroundColor:
                                (isPlayingItem ||
                                    widget.selectedAyahId ==
                                        ayah.globalAyahNumber)
                                ? (widget.readingMode == MushafReadingMode.navy
                                          ? const Color(0xFF35355F)
                                          : isPlayingItem
                                          ? AppTheme.accentGold
                                          : AppTheme.primaryEmerald)
                                      .withValues(alpha: 0.1)
                                : null,
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: AyahSymbol(
                              ayahNumber: ayah.ayahNumber,
                              color: isPlayingItem
                                  ? (widget.readingMode ==
                                            MushafReadingMode.navy
                                        ? Colors.white
                                        : AppTheme.accentGold)
                                  : AppTheme.primaryEmerald,
                              scale: widget.scale,
                              readingMode: widget.readingMode,
                            ),
                          ),
                        ),
                      ],
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

      final firstPageOfSurah = quran.getPageNumber(surahNum, 1);
      final shouldShowBanner = widget.page.pageNumber == firstPageOfSurah;

      surahWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (shouldShowBanner) ...[
              const SizedBox(height: 8),
              SurahHeaderWidget(
                key:
                    widget.initialSurah == surahNum &&
                        widget.initialAyah == null
                    ? _headerKey
                    : null,
                surahNumber: surahNum,
                scale: widget.scale,
                readingMode: widget.readingMode,
              ),
            ],
            if (isNewSurah && surahNum != 1 && surahNum != 9)
              BasmalaWidget(scale: widget.scale),
            const SizedBox(height: 8),
            // Ayahs flow continuously with a subtle divider between them
            for (int i = 0; i < ayahWidgets.length; i++) ...[
              ayahWidgets[i],
              if (i < ayahWidgets.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 32.0,
                  ),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color:
                        (widget.readingMode == MushafReadingMode.navy
                                ? Colors.white
                                : AppTheme.accentGold)
                            .withValues(alpha: 0.15),
                  ),
                ),
            ],
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

    return BlocListener<AudioBloc, AudioState>(
      listenWhen: (previous, current) =>
          previous.currentAyah != current.currentAyah &&
          current.currentAyah != null,
      listener: (context, state) {
        final targetKey = _ayahKeyMap[state.currentAyah];
        if (targetKey != null && targetKey.currentContext != null) {
          final isFirstAyah =
              state.currentAyah == widget.page.ayahs.first.globalAyahNumber;

          if (isFirstAyah) {
            // Scroll to absolute top to preserve the 70px safe area padding
            Scrollable.of(context).position.animateTo(
              0.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          } else {
            Scrollable.ensureVisible(
              targetKey.currentContext!,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
              alignment: 0.5, // requested to be centered
            );
          }
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Padding(
              // Horizontal padding for authentic Mushaf feel.
              // Note: top padding is handled by the parent ScrollView (top: 70)
              // to avoid the fixed AppBar/Header overlap.
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 0,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: surahWidgets,
              ),
            ),
            Center(child: SizedBox(key: _centerKey, width: 10, height: 10)),
          ],
        ),
      ),
    );
  }

  int _getGlobalId(int surah, int ayah) {
    int currentGlobal = 0;
    for (int s = 1; s < surah; s++) {
      currentGlobal += quran.getVerseCount(s);
    }
    return currentGlobal + ayah;
  }

  /// Cleans the Quranic text from problematic characters and fixes specific glyph issues.
  String _cleanQuranText(String text) {
    return text
        // Remove Byte Order Mark (BOM) if present
        .replaceAll('\ufeff', '')
        // Fix for specialized symbols at word ends/positions that some fonts struggle with
        // Arabic Small Low Meem (U+06ED) sometimes causes issues with stacking
        // .replaceAll('\u06ed', '\u06e8') // Only if necessary
        // Remove any Zero Width non-joiner if present but used incorrectly
        .replaceAll('\u200c', '')
        .trim();
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
