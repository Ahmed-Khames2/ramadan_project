import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran/quran.dart' as quran;
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'package:ramadan_project/features/quran/presentation/widgets/mushaf/ayah_context_menu.dart';
import 'package:ramadan_project/features/quran/presentation/widgets/continuous_mushaf_widget.dart';
import 'package:ramadan_project/features/audio/presentation/bloc/audio_bloc.dart';
import 'package:ramadan_project/features/quran/presentation/widgets/reciter_picker_sheet.dart';
import 'package:ramadan_project/features/quran/presentation/widgets/mushaf/page_header_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ramadan_project/features/quran/presentation/widgets/bookmarks_sheet.dart';
import 'package:ramadan_project/features/favorites/presentation/ayah_interaction_sheet.dart';
import 'package:ramadan_project/features/quran/presentation/widgets/quran_index_drawer.dart';
import 'package:ramadan_project/features/quran/presentation/bloc/quran_settings_cubit.dart';

class MushafPageView extends StatefulWidget {
  final int initialPage;
  final int? initialSurah;
  final int? initialAyah;
  final bool shouldSaveProgress;
  final ValueChanged<int>? onPageChanged;

  const MushafPageView({
    super.key,
    this.initialPage = 1,
    this.initialSurah,
    this.initialAyah,
    this.shouldSaveProgress = true,
    this.onPageChanged,
  });

  @override
  State<MushafPageView> createState() => _MushafPageViewState();
}

class _MushafPageViewState extends State<MushafPageView> {
  late int _currentPage;
  late Future<void> _initFuture;
  late PageController _portraitController;
  static const int _totalPages = 604;
  bool _showControls = false;
  Timer? _hideTimer;
  bool _isCurrentPageBookmarked = false;
  int? _selectedAyah;
  bool _isInitialEntry = true;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _initFuture = _initialize();
    WakelockPlus.enable();
    _portraitController = PageController(
      initialPage: _portraitIndexForPage(_currentPage),
    );

    // Detect if audio is already active to show controls/mini-player correctly
    final audioState = context.read<AudioBloc>().state;
    final isCurrentlyActive =
        audioState.status != AudioStatus.initial || audioState.lastAyah != null;

    if (isCurrentlyActive) {
      _isInitialEntry = false;
    }
  }

  Future<void> _initialize() async {
    final repo = context.read<QuranRepository>();
    await repo.init();
    _refreshBookmarkState();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    context.read<QuranSettingsCubit>().updateForAppBrightness(isDark);

    final initialSurah = quran.getPageData(_currentPage).first['surah'] as int;
    repo.preloadTafsir(initialSurah);
  }

  void _refreshBookmarkState() {
    final progress = context.read<QuranRepository>().getProgress();
    final bookmarks = progress?.bookmarks ?? [];
    if (mounted) {
      setState(() {
        _isCurrentPageBookmarked = bookmarks.contains(_currentPage);
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final repo = context.read<QuranRepository>();
    if (_isCurrentPageBookmarked) {
      await repo.removeBookmark(_currentPage);
    } else {
      await repo.saveBookmark(_currentPage);
    }
    _refreshBookmarkState();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    WakelockPlus.disable();
    _portraitController.dispose();
    super.dispose();
  }

  void _updateFontScale(double scale) {
    context.read<QuranSettingsCubit>().updateFontScale(scale);
  }

  Future<void> _saveBookmark(int page) async {
    try {
      final pageData = await context.read<QuranRepository>().getPage(page);
      if (pageData.ayahs.isNotEmpty) {
        final firstAyah = pageData.ayahs.first;
        final juz = quran.getJuzNumber(
          firstAyah.surahNumber,
          firstAyah.ayahNumber,
        );

        await context.read<QuranRepository>().saveLastRead(
          page,
          firstAyah.ayahNumber,
          surahNumber: firstAyah.surahNumber,
          juzNumber: juz,
        );
      }
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  int _portraitIndexForPage(int page) => page - 1;
  int _pageForPortraitIndex(int index) => index + 1;

  int _getPageFromGlobalId(int globalId) {
    return context.read<QuranRepository>().getPageFromGlobalId(globalId);
  }

  void _cycleReadingMode(bool isAppDark) {
    context.read<QuranSettingsCubit>().cycleReadingMode(isAppDark);
  }

  Color _getReadingModeBackground(MushafReadingMode mode) {
    switch (mode) {
      case MushafReadingMode.white:
        return AppTheme.surfaceWhite;
      case MushafReadingMode.beige:
        return AppTheme.mushafBeige;
      case MushafReadingMode.dark:
        return AppTheme.surfaceDark;
      case MushafReadingMode.navy:
        return AppTheme.mushafNavy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAppDark = theme.brightness == Brightness.dark;

    return BlocBuilder<QuranSettingsCubit, QuranSettingsState>(
      builder: (context, settings) {
        final bgColor = _getReadingModeBackground(settings.readingMode);

        return MultiBlocListener(
          listeners: [
            BlocListener<AudioBloc, AudioState>(
              listenWhen: (previous, current) =>
                  previous.currentAyah != current.currentAyah &&
                  current.currentAyah != null,
              listener: (context, state) {
                final audioPage = _getPageFromGlobalId(state.currentAyah!);
                if (audioPage != _currentPage &&
                    _portraitController.hasClients) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    if ((audioPage - _currentPage).abs() <= 1) {
                      _portraitController.animateToPage(
                        _portraitIndexForPage(audioPage),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _portraitController.jumpToPage(
                        _portraitIndexForPage(audioPage),
                      );
                    }
                  });
                }
              },
            ),
            BlocListener<AudioBloc, AudioState>(
              listener: (context, state) {
                if (state.status == AudioStatus.error &&
                    state.errorMessage != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
                }
              },
            ),
          ],
          child: Scaffold(
            drawer: QuranIndexDrawer(
              onPageSelected: (page) {
                _portraitController.jumpToPage(_portraitIndexForPage(page));
              },
              onReadingModeToggle: () => _cycleReadingMode(isAppDark),
              onFontScaleChanged: _updateFontScale,
              onBookmarkListTap: _showBookmarksSheet,
              currentFontScale: settings.fontScale,
              readingMode: settings.readingMode,
            ),
            backgroundColor: bgColor,
            body: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  _buildMainContent(bgColor, settings),
                  if (_selectedAyah != null)
                    _buildAyahContextMenuOverlay(context, settings.readingMode),
                  _buildBottomAudioBar(bgColor),
                  _buildMiniPlayer(),
                  _buildTopHeader(bgColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(Color bgColor, QuranSettingsState settings) {
    return GestureDetector(
      onTap: () {
        if (_selectedAyah != null) {
          setState(() => _selectedAyah = null);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: FutureBuilder(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryEmerald,
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("خطأ في تحميل البيانات: ${snapshot.error}"),
              );
            }

            return PageView.builder(
              key: ValueKey('portrait_${widget.initialPage}'),
              controller: _portraitController,
              itemCount: _totalPages,
              reverse: false,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return ContinuousMushafPageWidget(
                  pageNumber: _pageForPortraitIndex(index),
                  fontScale: settings.fontScale,
                  backgroundColor: bgColor,
                  initialSurah: widget.initialSurah,
                  initialAyah: widget.initialAyah,
                  isBookmarked: _currentPage == _pageForPortraitIndex(index)
                      ? _isCurrentPageBookmarked
                      : false,
                  onBookmarkTap: _toggleBookmark,
                  readingMode: settings.readingMode,
                  selectedAyahId: _selectedAyah,
                  onAyahTap: (ayah) {
                    setState(() => _selectedAyah = ayah.globalAyahNumber);
                  },
                  onShowControls: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && !_showControls) {
                        setState(() => _showControls = true);
                      }
                    });
                  },
                  onHideControls: () {
                    final audioState = context.read<AudioBloc>().state;
                    final isAudioActive =
                        audioState.status == AudioStatus.playing ||
                        audioState.status == AudioStatus.loading;

                    if (mounted &&
                        _showControls &&
                        _selectedAyah == null &&
                        !isAudioActive) {
                      setState(() => _showControls = false);
                    }
                  },
                  onSearchTap: () {},
                  onMenuTap: () {
                    // Fix: Use the scaffold key or builder context if needed
                    // but Scaffold.of(context) works if called within a builder down the tree.
                    // Here we are inside MushafPageView's build, but down in a PageView.
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _onPageChanged(int index) {
    _currentPage = _pageForPortraitIndex(index);
    setState(() {
      _selectedAyah = null;
    });

    final currentSurah = quran.getPageData(_currentPage).first['surah'] as int;
    context.read<QuranRepository>().preloadTafsir(currentSurah);

    if (widget.shouldSaveProgress) {
      _saveBookmark(_currentPage);
    }
    _refreshBookmarkState();
    widget.onPageChanged?.call(_currentPage);
  }

  Widget _buildBottomAudioBar(Color bgColor) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      bottom: _showControls ? 20 : -250,
      left: 16,
      right: 16,
      child: _AudioBar(
        backgroundColor: bgColor,
        onClose: () {
          setState(() {
            _showControls = false;
            _isInitialEntry = false;
          });
          context.read<AudioBloc>().add(const AudioStop());
        },
        onCollapse: () => setState(() {
          _showControls = false;
          _isInitialEntry = false;
        }),
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        final bool isAudioActive =
            state.status != AudioStatus.initial || state.lastAyah != null;

        if (!isAudioActive || _showControls || _isInitialEntry) {
          return const SizedBox.shrink();
        }

        final isPlaying = state.status == AudioStatus.playing;
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          bottom: 20,
          left: 20,
          child: GestureDetector(
            onTap: () => setState(() {
              _showControls = true;
              _isInitialEntry = false;
            }),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryEmerald,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryEmerald.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: isPlaying ? 28 : 32,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopHeader(Color bgColor) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      top: 0,
      left: 0,
      right: 0,
      child: FutureBuilder<QuranPage>(
        future: context.read<QuranRepository>().getPage(_currentPage),
        builder: (context, snapshot) {
          final pageData = snapshot.data;
          return PageHeaderWidget(
            page:
                pageData ??
                QuranPage(
                  pageNumber: _currentPage,
                  ayahs: [],
                  surahName: '',
                  juzNumber: 1,
                ),
            backgroundColor: bgColor,
            onSearchTap: () {},
            onMenuTap: () {
              Scaffold.of(context).openDrawer();
            },
            readingMode: context.read<QuranSettingsCubit>().state.readingMode,
          );
        },
      ),
    );
  }

  Widget _buildAyahContextMenuOverlay(
    BuildContext context,
    MushafReadingMode readingMode,
  ) {
    if (_selectedAyah == null) return const SizedBox.shrink();

    final pageData = quran.getPageData(_currentPage);
    Ayah? selectedAyahObj;

    for (var s in pageData) {
      final surahNum = s['surah'] as int;
      final start = s['start'] as int;
      final end = s['end'] as int;

      int currentGlobal = 0;
      for (int i = 1; i < surahNum; i++) {
        currentGlobal += quran.getVerseCount(i);
      }

      if (_selectedAyah! >= currentGlobal + start &&
          _selectedAyah! <= currentGlobal + end) {
        final verseNum = _selectedAyah! - currentGlobal;
        selectedAyahObj = Ayah(
          surahNumber: surahNum,
          ayahNumber: verseNum,
          text: quran.getVerse(surahNum, verseNum),
          surahName: quran.getSurahNameArabic(surahNum),
          pageNumber: _currentPage,
          globalAyahNumber: _selectedAyah!,
          isSajda: quran.isSajdahVerse(surahNum, verseNum),
        );
        break;
      }
    }

    if (selectedAyahObj == null) return const SizedBox.shrink();

    return Stack(
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedAyah = null),
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),
        AyahContextMenu(
          ayah: selectedAyahObj,
          onDismiss: () => setState(() => _selectedAyah = null),
          onTafsir: (ayah) {
            setState(() => _selectedAyah = null);
            _showTafsirSheet(ayah, readingMode);
          },
          onPlay: (ayah) {
            setState(() => _selectedAyah = null);
            _playAyah(ayah);
          },
          onPlaySequential: (ayah) {
            setState(() => _selectedAyah = null);
            _autoPlayFrom(ayah);
          },
          onPlaySurah: (ayah) {
            setState(() => _selectedAyah = null);
            _playSurah(ayah);
          },
          onShare: (ayah) {
            setState(() => _selectedAyah = null);
            _shareAyah(ayah);
          },
          readingMode: readingMode,
        ),
      ],
    );
  }

  void _playAyah(Ayah ayah) {
    setState(() {
      _showControls = true;
      _isInitialEntry = false;
    });
    final globalId = ayah.globalAyahNumber;
    if (globalId > 0) {
      context.read<AudioBloc>().add(AudioPlayAyah(globalId));
    }
  }

  void _playSurah(Ayah ayah) {
    setState(() {
      _showControls = true;
      _isInitialEntry = false;
    });
    final surah = ayah.surahNumber;
    final endAyah = quran.getVerseCount(surah);

    final List<int> globalIds = [];
    int globalBase = 0;
    for (int s = 1; s < surah; s++) {
      globalBase += quran.getVerseCount(s);
    }

    for (int i = 1; i <= endAyah; i++) {
      globalIds.add(globalBase + i);
    }

    if (globalIds.isNotEmpty) {
      context.read<AudioBloc>().add(AudioPlayRange(globalIds));
    }
  }

  void _autoPlayFrom(Ayah ayah) {
    setState(() {
      _showControls = true;
      _isInitialEntry = false;
    });
    final surah = ayah.surahNumber;
    final startAyah = ayah.ayahNumber;
    final endAyah = quran.getVerseCount(surah);

    final List<int> globalIds = [];
    int globalBase = 0;
    for (int s = 1; s < surah; s++) {
      globalBase += quran.getVerseCount(s);
    }

    for (int i = startAyah; i <= endAyah; i++) {
      globalIds.add(globalBase + i);
    }

    if (globalIds.isNotEmpty) {
      context.read<AudioBloc>().add(AudioPlayRange(globalIds));
    }
  }

  void _shareAyah(Ayah ayah) {
    final text = quran.getVerse(
      ayah.surahNumber,
      ayah.ayahNumber,
      verseEndSymbol: true,
    );
    final shareText =
        '$text\n\n[${quran.getSurahNameArabic(ayah.surahNumber)} : ${ayah.ayahNumber}]';
    Share.share(shareText);
  }

  void _showTafsirSheet(Ayah ayah, MushafReadingMode readingMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AyahInteractionSheet(
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumber,
        ayahId: ayah.globalAyahNumber,
        readingMode: readingMode,
      ),
    );
  }

  void _showBookmarksSheet() {
    BookmarksSheet.show(context);
  }
}

// Extracted audio bar widget
class _AudioBar extends StatelessWidget {
  final Color backgroundColor;
  final VoidCallback onClose;
  final VoidCallback onCollapse;

  const _AudioBar({
    required this.backgroundColor,
    required this.onClose,
    required this.onCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = backgroundColor;
    final borderColor = AppTheme.primaryEmerald.withValues(alpha: 0.3);
    final iconFg = isDark ? Colors.white70 : Colors.black87;

    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        if (state.status == AudioStatus.initial && state.lastAyah == null) {
          return const SizedBox.shrink();
        }

        final isPlaying = state.status == AudioStatus.playing;
        final isBuffering = state.status == AudioStatus.loading;
        final reciterName = state.selectedReciter.arabicName;

        return Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildReciterPill(context, reciterName),
                const SizedBox(height: 12),
                _buildControls(context, isPlaying, isBuffering, iconFg),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReciterPill(BuildContext context, String reciterName) {
    return InkWell(
      onTap: () => ReciterPickerSheet.show(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryEmerald.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              reciterName,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryEmerald,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.primaryEmerald,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    bool isPlaying,
    bool isBuffering,
    Color iconFg,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _compactBtn(
          icon: Icons.close_rounded,
          color: iconFg.withOpacity(0.6),
          onTap: () {
            context.read<AudioBloc>().add(const AudioStop());
            onClose();
          },
          size: 20,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _compactBtn(
              icon: Icons.skip_next_rounded,
              onTap: () => context.read<AudioBloc>().add(const AudioSkipNext()),
              color: iconFg,
              size: 24,
            ),
            const SizedBox(width: 16),
            _buildPlayButton(context, isPlaying, isBuffering),
            const SizedBox(width: 16),
            _compactBtn(
              icon: Icons.skip_previous_rounded,
              onTap: () =>
                  context.read<AudioBloc>().add(const AudioSkipPrevious()),
              color: iconFg,
              size: 24,
            ),
          ],
        ),
        _compactBtn(
          icon: Icons.keyboard_arrow_down_rounded,
          color: iconFg.withOpacity(0.6),
          onTap: onCollapse,
          size: 22,
        ),
      ],
    );
  }

  Widget _buildPlayButton(
    BuildContext context,
    bool isPlaying,
    bool isBuffering,
  ) {
    return GestureDetector(
      onTap: () {
        final bloc = context.read<AudioBloc>();
        isPlaying
            ? bloc.add(const AudioPause())
            : bloc.add(const AudioResume());
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: AppTheme.primaryEmerald,
          shape: BoxShape.circle,
        ),
        child: isBuffering
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
      ),
    );
  }

  Widget _compactBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white70,
    double size = 24,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}
