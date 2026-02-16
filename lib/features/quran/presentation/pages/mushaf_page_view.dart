import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'package:ramadan_project/features/audio/presentation/widgets/ayah_audio_control.dart';
import 'package:ramadan_project/features/quran/presentation/widgets/continuous_mushaf_widget.dart';

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
    _portraitController =
        PageController(initialPage: _portraitIndexForPage(_currentPage));
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

  void _goPreviousPage(Orientation orientation) {
    final step = orientation == Orientation.landscape ? 2 : 1;
    final target = (_currentPage - step).clamp(1, _totalPages);
    _goToPage(target);
    if (orientation == Orientation.landscape) {
      _landscapeController.animateToPage(
        _landscapeIndexForPage(target),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _portraitController.animateToPage(
        _portraitIndexForPage(target),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _goNextPage(Orientation orientation) {
    final step = orientation == Orientation.landscape ? 2 : 1;
    final target = (_currentPage + step).clamp(1, _totalPages);
    _goToPage(target);
    if (orientation == Orientation.landscape) {
      _landscapeController.animateToPage(
        _landscapeIndexForPage(target),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _portraitController.animateToPage(
        _portraitIndexForPage(target),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _ensureControllers(Orientation orientation) {
    if (_lastOrientation == orientation) return;
    _lastOrientation = orientation;
    _portraitController.dispose();
    _landscapeController.dispose();
    _portraitController =
        PageController(initialPage: _portraitIndexForPage(_currentPage));
    _landscapeController = PageController(
      initialPage: _landscapeIndexForPage(_currentPage),
    );
  }

  int _portraitIndexForPage(int page) => _totalPages - page;

  int _pageForPortraitIndex(int index) => _totalPages - index;

  int _landscapeIndexForPage(int page) =>
      ((_totalPages - page - 1) / 2).floor();

  int _rightPageForLandscapeIndex(int index) =>
      _totalPages - (index * 2 + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
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
                              child: MushafPageWidget(
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
                      child: _ZoomPill(onZoomIn: _zoomIn, onZoomOut: _zoomOut),
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

class _SideNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SideNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.white.withOpacity(0.9),
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.4),
            ),
            child: Icon(icon, color: const Color(0xFF2B1C00), size: 30),
          ),
        ),
      ),
    );
  }
}

class _ZoomPill extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _ZoomPill({required this.onZoomIn, required this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      elevation: 3,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1.4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 20),
              color: const Color(0xFF2B1C00),
              onPressed: onZoomOut,
              tooltip: 'تصغير',
            ),
            Container(width: 1, height: 22, color: const Color(0xFFD4AF37)),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              color: const Color(0xFF2B1C00),
              onPressed: onZoomIn,
              tooltip: 'تكبير',
            ),
          ],
        ),
      ),
    );
  }
}

class MushafPageWidget extends StatefulWidget {
  final int pageNumber;
  final double fontScale;
  const MushafPageWidget({
    super.key,
    required this.pageNumber,
    required this.fontScale,
  });

  @override
  State<MushafPageWidget> createState() => _MushafPageWidgetState();
}

class _MushafPageWidgetState extends State<MushafPageWidget> {
  late Future<QuranPage> _pageData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(MushafPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNumber != widget.pageNumber) {
      _loadData();
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

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
          ),
          child: Column(
            children: [
              _buildHeader(page),
              const Divider(height: 1, color: Color(0xFFD4AF37)),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: page.ayahs.length,
                  itemBuilder: (context, index) {
                    final ayah = page.ayahs[index];
                    return _buildAyahItem(context, ayah);
                  },
                ),
              ),
              const Divider(height: 1, color: Color(0xFFD4AF37)),
              _buildFooter(page),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(QuranPage page) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: const Color(0xFFFAF7F0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "سورة ${page.surahName}",
            style: const TextStyle(
              fontFamily: 'UthmanTaha',
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "الجزء ${page.juzNumber}",
            style: const TextStyle(
              fontFamily: 'UthmanTaha',
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(QuranPage page) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: const Color(0xFFFAF7F0),
      alignment: Alignment.center,
      child: Text(
        "${page.pageNumber}",
        style: const TextStyle(fontFamily: 'UthmanTaha'),
      ),
    );
  }

  Widget _buildAyahItem(BuildContext context, Ayah ayah) {
    final fontSize = (22 * widget.fontScale).clamp(16, 40).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: InkWell(
        onLongPress: () => _showTafsir(context, ayah),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                ayah.text,
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'UthmanTaha',
                  fontSize: fontSize,
                  height: 2.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/ayah_symbol.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: Text(
                      "${ayah.ayahNumber}",
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 36,
                    child: AyahAudioControl(ayahNumber: ayah.globalAyahNumber),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTafsir(BuildContext context, Ayah ayah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "التفسير الميسر",
                style: TextStyle(
                  fontFamily: 'UthmanTaha',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Divider(),
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
                      child: Text(
                        snapshot.data ?? "لا يوجد تفسير",
                        textAlign: TextAlign.justify,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontSize: 16, height: 1.6),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
