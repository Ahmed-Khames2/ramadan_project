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
  final bool shouldSaveProgress;
  final ValueChanged<int>? onPageChanged;

  const MushafPageView({
    super.key,
    this.initialPage = 1,
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

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.text_fields, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        "حجم الخط",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      const Text("A", style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppTheme.primaryEmerald,
                            inactiveTrackColor: AppTheme.primaryEmerald
                                .withOpacity(0.2),
                            thumbColor: AppTheme.primaryEmerald,
                            overlayColor: AppTheme.primaryEmerald.withOpacity(
                              0.12,
                            ),
                          ),
                          child: Slider(
                            value: _fontScale,
                            min: 0.8,
                            max: 2.5,
                            divisions: 17,
                            onChanged: (value) {
                              setModalState(() => _fontScale = value);
                              _updateFontScale(value);
                            },
                          ),
                        ),
                      ),
                      const Text("A", style: TextStyle(fontSize: 28)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
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

                        return Directionality(
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
                                  quran.getPageData(_currentPage).first['surah']
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
                                onShowControls: () {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted && !_showControls) {
                                      setState(() => _showControls = true);
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
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Top AppBar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: _showControls ? 0 : -100,
                left: 0,
                right: 0,
                child: AppBar(
                  title: const Text(
                    'المصحف الشريف',
                    style: TextStyle(
                      fontFamily: 'UthmanTaha',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: AppTheme.primaryEmerald,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    IconButton(
                      onPressed: _showSettings,
                      icon: const Icon(Icons.format_size),
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: _showControls
                    ? 0
                    : -200, // Increased offset for full height
                left: 0,
                right: 0,
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

        return Container(
          child: Listener(
            onPointerDown: (_) => _resetHideTimer(),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryEmerald,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ), // Normal top-only rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Removed Handle for cleaner look
                    // Progress Slider
                    Row(
                      children: [
                        Text(
                          _formatDuration(currentPosition),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                              activeTrackColor: AppTheme.accentGold,
                              inactiveTrackColor: Colors.white24,
                              thumbColor: AppTheme.accentGold,
                              overlayColor: AppTheme.accentGold.withOpacity(
                                0.2,
                              ),
                            ),
                            child: Slider(
                              value: currentPosition.inMilliseconds
                                  .toDouble()
                                  .clamp(
                                    0.0,
                                    totalDuration.inMilliseconds.toDouble() > 0
                                        ? totalDuration.inMilliseconds
                                              .toDouble()
                                        : 1.0,
                                  ),
                              max: totalDuration.inMilliseconds.toDouble() > 0
                                  ? totalDuration.inMilliseconds.toDouble()
                                  : 1.0,
                              onChanged: (value) {
                                context.read<AudioBloc>().add(
                                  AudioSeek(
                                    Duration(milliseconds: value.toInt()),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Text(
                          _formatDuration(totalDuration),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    // Main Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Stop/Close
                        // _buildCompactIconButton(
                        //   icon: Icons.close_rounded,
                        //   onPressed: () =>
                        //       context.read<AudioBloc>().add(const AudioStop()),
                        //   tooltip: 'إغلاق',
                        // ),
                        // Skip Previous
                        SizedBox(width: 20),
                        _buildCompactIconButton(
                          icon: Icons.skip_previous_rounded,
                          onPressed: () => context.read<AudioBloc>().add(
                            const AudioSkipPrevious(),
                          ),
                          tooltip: 'الآية السابقة',
                        ),
                        // Play/Pause Center
                        IconButton(
                          onPressed: () {
                            if (isPlaying) {
                              context.read<AudioBloc>().add(const AudioPause());
                            } else if (state.status == AudioStatus.paused) {
                              context.read<AudioBloc>().add(
                                const AudioResume(),
                              );
                            } else if (state.lastAyah != null) {
                              context.read<AudioBloc>().add(
                                AudioPlayAyah(state.lastAyah!),
                              );
                            }
                          },
                          iconSize: 56,
                          icon: isBuffering
                              ? const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: AppTheme.accentGold,
                                  ),
                                )
                              : Icon(
                                  isPlaying
                                      ? Icons.pause_circle_filled_rounded
                                      : Icons.play_circle_filled_rounded,
                                  color: Colors.white,
                                ),
                        ),
                        // Skip Next
                        _buildCompactIconButton(
                          icon: Icons.skip_next_rounded,
                          onPressed: () => context.read<AudioBloc>().add(
                            const AudioSkipNext(),
                          ),
                          tooltip: 'الآية التالية',
                        ),
                        // Repeat Toggle
                        _buildCompactIconButton(
                          icon: state.repeatOne
                              ? Icons.repeat_one_rounded
                              : Icons.repeat_rounded,
                          onPressed: () {
                            context.read<AudioBloc>().add(
                              AudioRepeatModeChanged(!state.repeatOne),
                            );
                          },
                          color: state.repeatOne
                              ? AppTheme.accentGold
                              : Colors.white70,
                          tooltip: 'تكرار',
                        ),
                      ],
                    ),
                    // Current Info Small
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        (state.currentAyah ?? state.lastAyah) != null
                            ? '${state.selectedReciter.arabicName} '
                            : 'جاهز للاستماع',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                        ),
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

  Widget _buildCompactIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color color = Colors.white70,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
