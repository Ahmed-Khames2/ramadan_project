import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'package:ramadan_project/features/audio/presentation/widgets/ayah_audio_control.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';
import 'package:ramadan_project/features/quran/presentation/widgets/quran_index_drawer.dart';
import 'package:ramadan_project/features/quran/presentation/widgets/continuous_mushaf_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadan_project/features/settings/presentation/pages/settings_page.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class MushafPageView extends StatefulWidget {
  final int initialPage;
  const MushafPageView({super.key, this.initialPage = 1});

  @override
  State<MushafPageView> createState() => _MushafPageViewState();
}

class _MushafPageViewState extends State<MushafPageView> {
  late int _currentPage;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _initFuture = context.read<QuranRepository>().init();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
    _saveBookmark(page);
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

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'quran_reader_hero_${widget.initialPage}',
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFBF7),
        appBar: AppBar(
          title: const Text(
            "القرآن الكريم",
            style: TextStyle(fontFamily: 'UthmanTaha', color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFFDFBF7),
          elevation: 0,
          foregroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            tooltip: 'العودة للرئيسية',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              tooltip: 'الإعدادات',
            ),
          ],
        ),
        body: FutureBuilder(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            return OrientationBuilder(
              builder: (context, orientation) {
                final isLandscape = orientation == Orientation.landscape;

                if (isLandscape) {
                  final int initialIndex = (_currentPage / 2).floor();
                  return PageView.builder(
                    key: ValueKey('landscape_$_currentPage$isLandscape'),
                    controller: PageController(initialPage: initialIndex),
                    itemCount: 303,
                    reverse: true,
                    onPageChanged: (index) {
                      if (index == 0) {
                        _currentPage = 1;
                      } else {
                        _currentPage = index * 2 + 1;
                      }
                    },
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Row(
                          children: [
                            const Expanded(
                              child: ContinuousMushafPageWidget(pageNumber: 1),
                            ),
                            Expanded(
                              child: Container(color: const Color(0xFFFDFBF7)),
                            ),
                          ],
                        );
                      }
                      final rightPageNum = index * 2 + 1;
                      final leftPageNum = index * 2;

                      if (leftPageNum > 604) {
                        return Row(
                          children: [
                            Expanded(
                              child: Container(color: const Color(0xFFFDFBF7)),
                            ),
                            if (rightPageNum <= 604)
                              const VerticalDivider(
                                width: 1,
                                color: Color(0xFFD4AF37),
                              ),
                            if (rightPageNum <= 604)
                              Expanded(
                                child: MushafPageWidget(
                                  pageNumber: rightPageNum,
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
                            ),
                          ),
                          const VerticalDivider(
                            width: 1,
                            color: Color(0xFFD4AF37),
                          ),
                          Expanded(
                            child: ContinuousMushafPageWidget(
                              pageNumber: leftPageNum,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  return PageView.builder(
                    key: ValueKey('portrait_$_currentPage$isLandscape'),
                    controller: PageController(initialPage: _currentPage - 1),
                    itemCount: 604,
                    reverse: true,
                    onPageChanged: (index) {
                      _currentPage = index + 1;
                      _saveBookmark(_currentPage);
                    },
                    itemBuilder: (context, index) {
                      return ContinuousMushafPageWidget(pageNumber: index + 1);
                    },
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class MushafPageWidget extends StatefulWidget {
  final int pageNumber;
  const MushafPageWidget({super.key, required this.pageNumber});

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
                style: const TextStyle(
                  fontFamily: 'UthmanTaha',
                  fontSize: 22,
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
