import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'package:ramadan_project/features/quran/presentation/widgets/continuous_mushaf_widget.dart';
import 'package:ramadan_project/features/quran/presentation/widgets/shared/quran_zoom_pill.dart';

class MushafPageView extends StatefulWidget {
  final int initialPage;
  const MushafPageView({super.key, this.initialPage = 1});

  @override
  State<MushafPageView> createState() => _MushafPageViewState();
}

class _MushafPageViewState extends State<MushafPageView> {
  late int _currentPage;
  late Future<void> _initFuture;
  double _fontScale = 1.0;
  double _gestureStartScale = 1.0;
  late PageController _portraitController;
  late PageController _landscapeController;
  Orientation? _lastOrientation;
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
    _landscapeController = PageController(
      initialPage: _landscapeIndexForPage(_currentPage),
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _portraitController.dispose();
    _landscapeController.dispose();
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

  void _zoomIn() {
    setState(() {
      _fontScale = (_fontScale + 0.1).clamp(0.8, 1.8);
    });
  }

  void _zoomOut() {
    setState(() {
      _fontScale = (_fontScale - 0.1).clamp(0.8, 1.8);
    });
  }

  void _onScaleStart(ScaleStartDetails details) {
    _gestureStartScale = _fontScale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale == 1.0) return;
    final nextScale = (_gestureStartScale * details.scale).clamp(0.8, 2.2);
    if (nextScale == _fontScale) return;
    setState(() {
      _fontScale = nextScale;
    });
  }

  // void _goPreviousPage(Orientation orientation) {
  //   final step = orientation == Orientation.landscape ? 2 : 1;
  //   final target = (_currentPage - step).clamp(1, _totalPages);
  //   _goToPage(target);
  //   if (orientation == Orientation.landscape) {
  //     _landscapeController.animateToPage(
  //       _landscapeIndexForPage(target),
  //       duration: const Duration(milliseconds: 250),
  //       curve: Curves.easeOut,
  //     );
  //   } else {
  //     _portraitController.animateToPage(
  //       _portraitIndexForPage(target),
  //       duration: const Duration(milliseconds: 250),
  //       curve: Curves.easeOut,
  //     );
  //   }
  // }

  // void _goNextPage(Orientation orientation) {
  //   final step = orientation == Orientation.landscape ? 2 : 1;
  //   final target = (_currentPage + step).clamp(1, _totalPages);
  //   _goToPage(target);
  //   if (orientation == Orientation.landscape) {
  //     _landscapeController.animateToPage(
  //       _landscapeIndexForPage(target),
  //       duration: const Duration(milliseconds: 250),
  //       curve: Curves.easeOut,
  //     );
  //   } else {
  //     _portraitController.animateToPage(
  //       _portraitIndexForPage(target),
  //       duration: const Duration(milliseconds: 250),
  //       curve: Curves.easeOut,
  //     );
  //   }
  // }

  void _ensureControllers(Orientation orientation) {
    if (_lastOrientation == orientation) return;
    _lastOrientation = orientation;
    _portraitController.dispose();
    _landscapeController.dispose();
    _portraitController = PageController(
      initialPage: _portraitIndexForPage(_currentPage),
    );
    _landscapeController = PageController(
      initialPage: _landscapeIndexForPage(_currentPage),
    );
  }

  int _portraitIndexForPage(int page) => _totalPages - page;

  int _pageForPortraitIndex(int index) => _totalPages - index;

  int _landscapeIndexForPage(int page) =>
      ((_totalPages - page - 1) / 2).floor();

  int _rightPageForLandscapeIndex(int index) => _totalPages - (index * 2 + 1);

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

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            child: OrientationBuilder(
              builder: (context, orientation) {
                _ensureControllers(orientation);
                final isLandscape = orientation == Orientation.landscape;

                Widget pageView;
                if (isLandscape) {
                  pageView = PageView.builder(
                    key: const ValueKey('landscape'),
                    controller: _landscapeController,
                    itemCount: 302,
                    reverse: false,
                    onPageChanged: (index) {
                      _currentPage = _rightPageForLandscapeIndex(index);
                    },
                    itemBuilder: (context, index) {
                      final rightPageNum = _rightPageForLandscapeIndex(index);
                      final leftPageNum = rightPageNum - 1;

                      if (rightPageNum < 1) {
                        return Row(
                          children: [
                            Expanded(
                              child: Container(color: const Color(0xFFFDFBF7)),
                            ),
                            Expanded(
                              child: Container(color: const Color(0xFFFDFBF7)),
                            ),
                          ],
                        );
                      }

                      if (leftPageNum < 1) {
                        return Row(
                          children: [
                            Expanded(
                              child: Container(color: const Color(0xFFFDFBF7)),
                            ),
                            const VerticalDivider(
                              width: 1,
                              color: Color(0xFFD4AF37),
                            ),
                            Expanded(
                              child: ContinuousMushafPageWidget(
                                pageNumber: rightPageNum,
                                fontScale: _fontScale,
                              ),
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: ContinuousMushafPageWidget(
                              pageNumber: rightPageNum,
                              fontScale: _fontScale,
                            ),
                          ),
                          const VerticalDivider(
                            width: 1,
                            color: Color(0xFFD4AF37),
                          ),
                          Expanded(
                            child: ContinuousMushafPageWidget(
                              pageNumber: leftPageNum,
                              fontScale: _fontScale,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  pageView = PageView.builder(
                    key: const ValueKey('portrait'),
                    controller: _portraitController,
                    itemCount: _totalPages,
                    reverse: false,
                    onPageChanged: (index) {
                      _currentPage = _pageForPortraitIndex(index);
                      _saveBookmark(_currentPage);
                    },
                    itemBuilder: (context, index) {
                      return ContinuousMushafPageWidget(
                        pageNumber: _pageForPortraitIndex(index),
                        fontScale: _fontScale,
                      );
                    },
                  );
                }

                return Stack(
                  children: [
                    pageView,
                    Positioned(
                      right: 12,
                      bottom: 16,
                      child: QuranZoomPill(
                        onZoomIn: _zoomIn,
                        onZoomOut: _zoomOut,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
