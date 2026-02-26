import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadan_project/features/audio/domain/entities/reciter.dart';
import 'package:ramadan_project/features/audio/domain/repositories/audio_repository.dart';
import 'package:rxdart/rxdart.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioPlayer _audioPlayer;
  final Dio _dio;
  List<int>? _activePlaylistAyahs;

  // ignore: close_sinks
  final _currentAyahController = BehaviorSubject<int?>();
  // ignore: close_sinks
  final _downloadProgressController = BehaviorSubject<Map<int, double>>.seeded(
    {},
  );
  final Map<int, CancelToken> _cancelTokens = {};

  AudioRepositoryImpl({AudioPlayer? audioPlayer, Dio? dio})
    : _audioPlayer = audioPlayer ?? AudioPlayer(),
      _dio = dio ?? Dio() {
    // Standard listeners moved to constructor to avoid leaks
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _currentAyahController.add(null);
      }
    });

    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null &&
          _activePlaylistAyahs != null &&
          index < _activePlaylistAyahs!.length) {
        _currentAyahController.add(_activePlaylistAyahs![index]);
      }
    });
  }

  @override
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  @override
  Stream<Duration> get durationStream =>
      _audioPlayer.durationStream.map((d) => d ?? Duration.zero);

  @override
  Stream<bool> get isPlayingStream => _audioPlayer.playingStream;

  @override
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  @override
  Stream<int?> get currentAyahStream => _currentAyahController.stream;

  @override
  Future<void> playAyah(int ayahNumber, Reciter reciter) async {
    try {
      // 1. Stop previous playback and reset session to ensure a clean state,
      // especially on Web where buffers might persist.
      await _audioPlayer.stop();
      _activePlaylistAyahs = null;

      if (kIsWeb) {
        final url = _getAudioUrl(ayahNumber, reciter);

        final mediaItem = _buildMediaItem(ayahNumber, reciter);

        // 2. Explicitly set initialPosition to Duration.zero
        await _audioPlayer.setAudioSource(
          AudioSource.uri(Uri.parse(url), tag: mediaItem),
          initialPosition: Duration.zero,
        );
      } else {
        final localPath = await _getLocalFilePath(ayahNumber, reciter);
        final file = File(localPath);

        final mediaItem = _buildMediaItem(ayahNumber, reciter);

        if (await file.exists()) {
          // 2. Explicitly set initialPosition to Duration.zero
          await _audioPlayer.setAudioSource(
            AudioSource.uri(Uri.file(localPath), tag: mediaItem),
            initialPosition: Duration.zero,
          );
        } else {
          // Check connectivity before trying to stream
          final connectivityResult = await Connectivity().checkConnectivity();
          final isOffline = connectivityResult.contains(
            ConnectivityResult.none,
          );

          if (isOffline) {
            throw Exception(
              "لا يوجد اتصال بالإنترنت ولم يتم تحميل هذه الآية مسبقاً.",
            );
          }

          final url = _getAudioUrl(ayahNumber, reciter);

          final source = LockCachingAudioSource(
            Uri.parse(url),
            cacheFile: File(localPath),
            tag: mediaItem,
          );
          // 2. Explicitly set initialPosition to Duration.zero
          await _audioPlayer.setAudioSource(
            source,
            initialPosition: Duration.zero,
          );
        }
      }

      _currentAyahController.add(ayahNumber);

      // DO NOT await play() as it blocks until audio finishes.
      // We want to return immediately so BLoC can update state to 'playing'.
      _audioPlayer.play();
    } catch (e) {
      throw Exception("Failed to play audio: $e");
    }
  }

  @override
  Future<void> playRange(List<int> ayahNumbers, Reciter reciter) async {
    try {
      await _audioPlayer.stop();
      _activePlaylistAyahs = null; // Clear immediately to prevent stale updates

      final localDir = await _getLocalDirectory(reciter);
      final List<AudioSource> sources = [];

      // Check existence and build sources in parallel for speed
      final existsResults = await Future.wait(
        ayahNumbers.map((ayah) async {
          final path = '${localDir.path}/$ayah.mp3';
          return await File(path).exists();
        }),
      );

      final connectivityResult = await Connectivity().checkConnectivity();
      final isOffline = connectivityResult.contains(ConnectivityResult.none);

      for (int i = 0; i < ayahNumbers.length; i++) {
        final ayah = ayahNumbers[i];
        final exists = existsResults[i];
        final path = '${localDir.path}/$ayah.mp3';

        final mediaItem = _buildMediaItem(ayah, reciter);

        if (exists) {
          sources.add(AudioSource.file(path, tag: mediaItem));
        } else {
          if (isOffline) {
            throw Exception("لا يوجد اتصال بالإنترنت لبعض الآيات في القائمة.");
          }
          final url = _getAudioUrl(ayah, reciter);
          sources.add(
            LockCachingAudioSource(
              Uri.parse(url),
              cacheFile: File(path),
              tag: mediaItem,
            ),
          );
        }
      }

      final playlist = ConcatenatingAudioSource(children: sources);

      // Crucial: Only set the active ayahs list right before setting the source
      _activePlaylistAyahs = ayahNumbers;

      await _audioPlayer.setAudioSource(
        playlist,
        initialPosition: Duration.zero,
      );

      _audioPlayer.play();
    } catch (e) {
      throw Exception("Failed to play range: $e");
    }
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentAyahController.add(null);
  }

  @override
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  Future<void> setReciter(Reciter reciter) async {
    // No-op for now in repository, logic handled in BLoC
  }

  @override
  Future<Reciter> getSavedReciter() async {
    throw UnimplementedError(); // Use ReciterRepository
  }

  @override
  Future<void> downloadAyah(int ayahNumber, Reciter reciter) async {
    if (kIsWeb || _cancelTokens.containsKey(ayahNumber)) return;

    final url = _getAudioUrl(ayahNumber, reciter);
    final savePath = await _getLocalFilePath(ayahNumber, reciter);
    final cancelToken = CancelToken();
    _cancelTokens[ayahNumber] = cancelToken;

    try {
      await _dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            final currentMap = Map<int, double>.from(
              _downloadProgressController.value,
            );
            currentMap[ayahNumber] = progress;
            _downloadProgressController.add(currentMap);
          }
        },
      );
    } catch (e) {
      // Ignore cancellations
      if (!CancelToken.isCancel(e as DioException)) {
        rethrow;
      }
    } finally {
      _cancelTokens.remove(ayahNumber);
      final currentMap = Map<int, double>.from(
        _downloadProgressController.value,
      );
      currentMap.remove(ayahNumber); // Remove progress when done
      _downloadProgressController.add(currentMap);
    }
  }

  @override
  Future<bool> isAyahDownloaded(int ayahNumber, Reciter reciter) async {
    if (kIsWeb) return false;
    final path = await _getLocalFilePath(ayahNumber, reciter);
    return File(path).exists();
  }

  @override
  Future<void> cancelDownload(int ayahNumber) async {
    _cancelTokens[ayahNumber]?.cancel();
    _cancelTokens.remove(ayahNumber);
  }

  @override
  Stream<double> getDownloadProgress(int ayahNumber) {
    return _downloadProgressController.stream
        .map((map) => map[ayahNumber] ?? 0.0)
        .distinct();
  }

  @override
  Stream<Map<int, double>> get downloadProgressStream =>
      _downloadProgressController.stream;

  @override
  Future<void> resume() async {
    await _audioPlayer.play();
  }

  String _getAudioUrl(int ayahNumber, Reciter reciter) {
    return 'https://cdn.islamic.network/quran/audio/128/${reciter.id}/$ayahNumber.mp3';
  }

  /// Builds a MediaItem for the audio player notification.
  /// Converts the global ayah number to a Surah name using the quran package.
  MediaItem _buildMediaItem(int ayahNumber, Reciter reciter) {
    // Convert global ayah number to surah/ayah
    int surahNumber = 1;
    int ayahInSurah = ayahNumber;
    int count = 0;
    for (int s = 1; s <= 114; s++) {
      final verseCount = quran.getVerseCount(s);
      if (count + verseCount >= ayahNumber) {
        surahNumber = s;
        ayahInSurah = ayahNumber - count;
        break;
      }
      count += verseCount;
    }
    final surahName = quran.getSurahNameArabic(surahNumber);
    return MediaItem(
      id: ayahNumber.toString(),
      album: reciter.arabicName,
      title: 'سورة $surahName - الآية $ayahInSurah',
      artist: reciter.arabicName,
    );
  }

  Future<String> _getLocalFilePath(int ayahNumber, Reciter reciter) async {
    if (kIsWeb) return '';
    final dir = await _getLocalDirectory(reciter);
    return '${dir.path}/$ayahNumber.mp3';
  }

  Future<Directory> _getLocalDirectory(Reciter reciter) async {
    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${dir.path}/audio/${reciter.id}');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  @override
  Future<void> setLoopMode(bool repeatOne) async {
    await _audioPlayer.setLoopMode(repeatOne ? LoopMode.one : LoopMode.off);
  }

  @override
  Future<bool> seekToNext() async {
    if (_audioPlayer.hasNext) {
      await _audioPlayer.seekToNext();
      await _audioPlayer.seek(Duration.zero);
      return true;
    }
    return false;
  }

  @override
  Future<bool> seekToPrevious() async {
    if (_audioPlayer.hasPrevious) {
      await _audioPlayer.seekToPrevious();
      await _audioPlayer.seek(Duration.zero);
      return true;
    }
    return false;
  }
}
