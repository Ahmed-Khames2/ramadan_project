import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'package:ramadan_project/features/quran/presentation/widgets/continuous_mushaf_widget.dart';
import 'package:ramadan_project/core/widgets/error_dialog.dart';
import 'package:ramadan_project/features/audio/presentation/bloc/audio_bloc.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';

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
  double _fontScale = 1.0;
  late Future<void> _initFuture;
  late PageController _portraitController;
  static const int _totalPages = 604;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _initFuture = _initialize();
    WakelockPlus.enable();
    _portraitController = PageController(
      initialPage: _portraitIndexForPage(_currentPage),
    );
    _resetHideTimer();
  }

  Future<void> _initialize() async {
    await context.read<QuranRepository>().init();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontScale = prefs.getDouble('mushaf_font_scale') ?? 1.0;
    });

    // Show instructional message only once
    final hasShownInstruction =
        prefs.getBool('mushaf_instruction_shown') ?? false;
    if (!hasShownInstruction) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMushafInstruction();
        prefs.setBool('mushaf_instruction_shown', true);
      });
    }

    // Preload initial page's surah tafsir
    final initialSurah = quran.getPageData(_currentPage).first['surah'] as int;
    context.read<QuranRepository>().preloadTafsir(initialSurah);
  }

  void _resetHideTimer() {
    _cancelHideTimer();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showControls) {
        final audioState = context.read<AudioBloc>().state;
        if (audioState.status == AudioStatus.playing) {
          setState(() {
            _showControls = false;
          });
        }
      }
    });
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _resetHideTimer();
    } else {
      _cancelHideTimer();
    }
  }

  void _showMushafInstruction() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.primaryEmerald),
            SizedBox(width: 12),
            Text(
              'تعلم الاستخدام',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'يمكنك الضغط على أي آية لعرض التفسير وسماع التلاوة بصوت القارئ المفضل لديك.',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'حسناً',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryEmerald,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cancelHideTimer();
    WakelockPlus.disable();
    _portraitController.dispose();
    super.dispose();
  }

  void _updateFontScale(double scale) async {
    setState(() {
      _fontScale = scale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('mushaf_font_scale', scale);
  }

  Future<void> _saveBookmark(int page) async {
    try {
      // Get page data to find the first Ayah and its details
      final pageData = await context.read<QuranRepository>().getPage(page);
      if (pageData.ayahs.isNotEmpty) {
        final firstAyah = pageData.ayahs.first;
        final juz = quran.getJuzNumber(
          firstAyah.surahNumber,
          firstAyah.ayahNumber,
        );

        // Save complete progress to repository
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
    int currentGlobal = 0;
    for (int s = 1; s <= 114; s++) {
      int vCount = quran.getVerseCount(s);
      if (currentGlobal + vCount >= globalId) {
        int v = globalId - currentGlobal;
        return quran.getPageNumber(s, v);
      }
      currentGlobal += vCount;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AudioBloc, AudioState>(
      listener: (context, state) {
        if (state.status == AudioStatus.error && state.errorMessage != null) {
          ErrorDialog.show(context, message: state.errorMessage!);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: DecorativeBackground(
          child: Stack(
            children: [
              // Content
              GestureDetector(
                onTap: _toggleControls,
                behavior: HitTestBehavior.opaque,
                child: SafeArea(
                  bottom: false,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: FutureBuilder(
                      future: _initFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryEmerald,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "خطأ في تحميل البيانات: ${snapshot.error}",
                            ),
                          );
                        }

                        return BlocListener<AudioBloc, AudioState>(
                          listenWhen: (previous, current) =>
                              previous.currentAyah != current.currentAyah &&
                              current.currentAyah != null &&
                              current.status == AudioStatus.playing,
                          listener: (context, state) {
                            final audioPage = _getPageFromGlobalId(
                              state.currentAyah!,
                            );

                            if (audioPage != _currentPage) {
                              // Only auto-flip if it's the next page or within reasonable range
                              if ((audioPage - _currentPage).abs() <= 1) {
                                _portraitController.animateToPage(
                                  _portraitIndexForPage(audioPage),
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeInOut,
                                );
                              }
                            }
                          },
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: PageView.builder(
                              key: ValueKey('portrait_${widget.initialPage}'),
                              controller: _portraitController,
                              itemCount: _totalPages,
                              reverse: false,
                              onPageChanged: (index) {
                                _currentPage = _pageForPortraitIndex(index);
                                setState(() {}); // Update title

                                // Preload tafsir for the new surah
                                final currentSurah =
                                    quran
                                            .getPageData(_currentPage)
                                            .first['surah']
                                        as int;
                                context.read<QuranRepository>().preloadTafsir(
                                  currentSurah,
                                );

                                if (widget.shouldSaveProgress) {
                                  _saveBookmark(_currentPage);
                                }
                                widget.onPageChanged?.call(_currentPage);
                              },
                              itemBuilder: (context, index) {
                                return ContinuousMushafPageWidget(
                                  pageNumber: _pageForPortraitIndex(index),
                                  fontScale: _fontScale,
                                  initialSurah: widget.initialSurah,
                                  initialAyah: widget.initialAyah,
                                  onShowControls: () {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted && !_showControls) {
                                            setState(
                                              () => _showControls = true,
                                            );
                                          }
                                          _resetHideTimer();
                                        });
                                  },
                                  onHideControls: () {
                                    if (mounted && _showControls) {
                                      setState(() => _showControls = false);
                                      _cancelHideTimer();
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Top Floating Back Button
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: _showControls ? 40 : -60,
                right: 20,
                child: FloatingActionButton.small(
                  onPressed: () => Navigator.of(context).pop(),
                  backgroundColor: theme.brightness == Brightness.dark
                      ? theme.colorScheme.surface
                      : Colors.white,
                  foregroundColor: AppTheme.primaryEmerald,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: theme.brightness == Brightness.dark
                        ? BorderSide(
                            color: AppTheme.primaryEmerald.withValues(
                              alpha: 0.3,
                            ),
                            width: 1,
                          )
                        : BorderSide.none,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ),
              // Floating Zoom Controls
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                right: _showControls ? 20 : -60,
                top: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoom_in',
                      onPressed: () =>
                          _updateFontScale((_fontScale + 0.1).clamp(0.8, 2.5)),
                      backgroundColor: theme.brightness == Brightness.dark
                          ? theme.colorScheme.surface
                          : Colors.white,
                      foregroundColor: AppTheme.primaryEmerald,
                      elevation: 4,
                      child: const Icon(Icons.add_rounded),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton.small(
                      heroTag: 'zoom_out',
                      onPressed: () =>
                          _updateFontScale((_fontScale - 0.1).clamp(0.8, 2.5)),
                      backgroundColor: theme.brightness == Brightness.dark
                          ? theme.colorScheme.surface
                          : Colors.white,
                      foregroundColor: AppTheme.primaryEmerald,
                      elevation: 4,
                      child: const Icon(Icons.remove_rounded),
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: _showControls ? 30 : -250,
                left: 20,
                right: 20,
                child: _buildBottomAudioBar(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAudioBar(ThemeData theme) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        if (state.status == AudioStatus.initial && state.lastAyah == null) {
          return const SizedBox.shrink();
        }

        final isPlaying = state.status == AudioStatus.playing;
        final isBuffering = state.status == AudioStatus.loading;
        final currentPosition = state.position;
        final totalDuration = state.duration;

        return Material(
          color: Colors.transparent,
          child: Listener(
            onPointerDown: (_) => _resetHideTimer(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: theme.brightness == Brightness.dark
                      ? [
                          theme.colorScheme.surface.withValues(alpha: 0.98),
                          theme.colorScheme.surface.withValues(alpha: 0.92),
                        ]
                      : [
                          AppTheme.primaryEmerald.withValues(alpha: 0.95),
                          AppTheme.primaryEmerald.withValues(alpha: 0.85),
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppTheme.accentGold.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    _formatDuration(currentPosition),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 5,
                        ),
                        activeTrackColor: AppTheme.accentGold,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: AppTheme.accentGold,
                      ),
                      child: Slider(
                        value: currentPosition.inMilliseconds.toDouble().clamp(
                          0.0,
                          totalDuration.inMilliseconds.toDouble() > 0
                              ? totalDuration.inMilliseconds.toDouble()
                              : 1.0,
                        ),
                        max: totalDuration.inMilliseconds.toDouble() > 0
                            ? totalDuration.inMilliseconds.toDouble()
                            : 1.0,
                        onChanged: (value) {
                          context.read<AudioBloc>().add(
                            AudioSeek(Duration(milliseconds: value.toInt())),
                          );
                        },
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(totalDuration),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildCompactIconButton(
                    icon: Icons.close_rounded,
                    onPressed: () =>
                        context.read<AudioBloc>().add(const AudioStop()),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color color = Colors.white70,
    double size = 28,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: size),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
