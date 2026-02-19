import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'ayah_symbol.dart';
import 'surah_header_widget.dart';
import 'basmala_widget.dart';
import 'package:ramadan_project/core/widgets/error_dialog.dart';

class MushafVerseBody extends StatefulWidget {
  final QuranPage page;
  final double scale;

  const MushafVerseBody({super.key, required this.page, required this.scale});

  @override
  State<MushafVerseBody> createState() => _MushafVerseBodyState();
}

class _MushafVerseBodyState extends State<MushafVerseBody> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _currentAyahId;
  final Connectivity _connectivity = Connectivity();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAyah(Ayah ayah) async {
    try {
      // 1. Check Internet Connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        if (mounted) {
          ErrorDialog.show(
            context,
            message:
                'لا يوجد اتصال بالإنترنت. يرجى التأكد من الاتصال لتشغيل التلاوة.',
          );
        }
        return;
      }

      final globalId = ayah.globalAyahNumber;
      if (globalId <= 0) return;

      final url =
          "https://cdn.islamic.network/quran/audio/128/ar.alafasy/$globalId.mp3";

      // If already playing this ayah and paused or completed, just resume (or restart)
      if (_currentAyahId == globalId) {
        if (_audioPlayer.processingState == ProcessingState.completed) {
          await _audioPlayer.seek(Duration.zero);
        }
        _audioPlayer.play();
        return;
      }

      _currentAyahId = globalId;

      // Use LockCachingAudioSource for temporary caching
      final audioSource = LockCachingAudioSource(Uri.parse(url));
      await _audioPlayer.setAudioSource(audioSource);
      _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(
          context,
          message: 'عذراً، حدث خطأ أثناء تشغيل الصوت: $e',
        );
      }
    }
  }

  void _pauseAyah() {
    _audioPlayer.pause();
  }

  void _showAyahDetails(Ayah ayah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return FutureBuilder<String>(
              future: context.read<QuranRepository>().getTafsir(
                ayah.surahNumber,
                ayah.ayahNumber,
              ),
              builder: (context, snapshot) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${ayah.surahName} (${ayah.ayahNumber})",
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                          StreamBuilder<PlayerState>(
                            stream: _audioPlayer.playerStateStream,
                            builder: (context, snapshot) {
                              final playerState = snapshot.data;
                              final isPlaying =
                                  (playerState?.playing ?? false) &&
                                  playerState?.processingState !=
                                      ProcessingState.completed;

                              return IconButton(
                                onPressed: isPlaying
                                    ? _pauseAyah
                                    : () => _playAyah(ayah),
                                icon: Icon(
                                  isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                  size: 56,
                                  color: const Color(0xFFFFD700),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        children: [
                          Text(
                            ayah.text,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'KFGQPCUthmanTahaNaskhRegular',
                              fontSize: 24,
                              height: 1.8,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            "التفسير الميسر:",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            const Center(child: CircularProgressIndicator())
                          else if (snapshot.hasError)
                            Text(
                              "خطأ في تحميل التفسير: ${snapshot.error}",
                              textAlign: TextAlign.right,
                            )
                          else
                            Text(
                              snapshot.data ?? "لا يوجد تفسير متاح",
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 17,
                                height: 1.7,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
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
          GestureDetector(
            onTap: () => _showAyahDetails(ayah),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
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
          ),
        );
      }

      final surahNum = surahAyahs.first.surahNumber;
      final isNewSurah = surahAyahs.first.ayahNumber == 1;

      surahWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            SurahHeaderWidget(surahNumber: surahNum, scale: widget.scale),
            if (isNewSurah && surahNum != 1 && surahNum != 9)
              BasmalaWidget(scale: widget.scale),
            const SizedBox(height: 12),
            ...ayahWidgets,
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
        child: Column(children: surahWidgets),
      ),
    );
  }
}
