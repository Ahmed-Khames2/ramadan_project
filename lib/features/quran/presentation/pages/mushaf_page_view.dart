import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'package:ramadan_project/features/quran/presentation/widgets/continuous_mushaf_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _initFuture = _initialize();
    WakelockPlus.enable();
    _portraitController = PageController(
      initialPage: _portraitIndexForPage(_currentPage),
    );
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
  }

  void _showMushafInstruction() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'يمكنك الضغط على أي آية لعرض التفسير وسماع التلاوة',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryEmerald,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
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
                        child: Slider(
                          value: _fontScale,
                          min: 0.8,
                          max: 2.5,
                          divisions: 17,
                          activeColor: const Color(0xFFFFD700),
                          onChanged: (value) {
                            setModalState(() => _fontScale = value);
                            _updateFontScale(value);
                          },
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
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          quran.getSurahNameArabic(
            quran.getPageData(_currentPage).first['surah'] as int,
          ),
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            color: Color(0xFFFFD700),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.format_size, color: Color(0xFFFFD700)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: FutureBuilder(
            future: _initFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text("خطأ في تحميل البيانات: ${snapshot.error}"),
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
                    if (widget.shouldSaveProgress) {
                      _saveBookmark(_currentPage);
                    }
                    widget.onPageChanged?.call(_currentPage);
                  },
                  itemBuilder: (context, index) {
                    return ContinuousMushafPageWidget(
                      pageNumber: _pageForPortraitIndex(index),
                      fontScale: _fontScale,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
