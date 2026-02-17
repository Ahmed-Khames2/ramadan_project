import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late Future<void> _initFuture;
  late PageController _portraitController;
  static const int _totalPages = 604;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _initFuture = context.read<QuranRepository>().init();
    WakelockPlus.enable();
    _portraitController = PageController(
      initialPage: _portraitIndexForPage(_currentPage),
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _portraitController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    final target = page.clamp(1, _totalPages);
    setState(() {
      _currentPage = target;
    });
    _saveBookmark(_currentPage);
  }

  Future<void> _saveBookmark(int page) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final pageData = await context.read<QuranRepository>().getPage(page);
      if (pageData.ayahs.isNotEmpty) {
        final firstAyah = pageData.ayahs.first;
        await prefs.setInt('last_read_page', page);
        await prefs.setInt('last_read_surah', firstAyah.surahNumber);
        await prefs.setInt('last_read_ayah', firstAyah.ayahNumber);
        await prefs.setInt(
          'last_read_juz',
          quran.getJuzNumber(firstAyah.surahNumber, firstAyah.ayahNumber),
        );
      }
    } catch (e) {
      // Silent fail
    }
  }

  int _portraitIndexForPage(int page) => _totalPages - page;

  int _pageForPortraitIndex(int index) => _totalPages - index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: FutureBuilder(
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

          return PageView.builder(
            key: const ValueKey('portrait'),
            controller: _portraitController,
            itemCount: _totalPages,
            reverse: false,
            onPageChanged: (index) {
              _currentPage = _pageForPortraitIndex(index);
              if (widget.shouldSaveProgress) {
                _saveBookmark(_currentPage);
              }
              widget.onPageChanged?.call(_currentPage);
            },
            itemBuilder: (context, index) {
              return ContinuousMushafPageWidget(
                pageNumber: _pageForPortraitIndex(index),
              );
            },
          );
        },
      ),
    );
  }
}
