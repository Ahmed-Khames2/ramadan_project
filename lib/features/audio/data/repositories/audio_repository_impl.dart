import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ramadan_project/features/audio/domain/entities/reciter.dart';
import 'package:ramadan_project/features/audio/domain/repositories/audio_repository.dart';
import 'package:rxdart/rxdart.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioPlayer _audioPlayer;
  final Dio _dio;

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
      // For playlist support (playRange)
      if (_audioPlayer.audioSource is ConcatenatingAudioSource) {
        final playlist = _audioPlayer.audioSource as ConcatenatingAudioSource;
        if (index != null && index < playlist.length) {
          // We need a way to map index back to ayahNumber
          // If we store the current range, we can map it here.
          // For now, playRange handles its own mapping if it's specialized.
        }
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
    print('AudioRepo: playAyah($ayahNumber, ${reciter.id})'); // DEBUG LOG
    try {
      final localPath = await _getLocalFilePath(ayahNumber, reciter);
      final file = File(localPath);

      if (await file.exists()) {
        print('AudioRepo: Playing from local file: $localPath'); // DEBUG LOG
        await _audioPlayer.setFilePath(localPath);
      } else {
        final url = _getAudioUrl(ayahNumber, reciter);
        print('AudioRepo: Playing from URL: $url'); // DEBUG LOG
        await _audioPlayer.setUrl(url);
      }

      _currentAyahController.add(ayahNumber);

      // DO NOT await play() as it blocks until audio finishes.
      // We want to return immediately so BLoC can update state to 'playing'.
      _audioPlayer.play();
    } catch (e) {
      print('AudioRepo: Error playing audio: $e'); // DEBUG LOG
      throw Exception("Failed to play audio: $e");
    }
  }

  @override
  Future<void> playRange(List<int> ayahNumbers, Reciter reciter) async {
    try {
      final List<AudioSource> sources = [];
      for (final ayah in ayahNumbers) {
        final localPath = await _getLocalFilePath(ayah, reciter);
        final file = File(localPath);

        if (await file.exists()) {
          sources.add(AudioSource.file(localPath, tag: ayah));
        } else {
          sources.add(
            AudioSource.uri(Uri.parse(_getAudioUrl(ayah, reciter)), tag: ayah),
          );
        }
      }

      final playlist = ConcatenatingAudioSource(children: sources);
      await _audioPlayer.setAudioSource(playlist);

      // Handle current ayah updates for playlists
      // This is better handled here since the list is specific to this call
      final subscription = _audioPlayer.currentIndexStream.listen((index) {
        if (index != null && index < ayahNumbers.length) {
          _currentAyahController.add(ayahNumbers[index]);
        }
      });

      // Ensure we clean up the subscription when audio stops/changes
      // (Simplified: in a real app we might manage this subscription better)

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
    if (_cancelTokens.containsKey(ayahNumber)) return;

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

  Future<String> _getLocalFilePath(int ayahNumber, Reciter reciter) async {
    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${dir.path}/audio/${reciter.id}');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return '${audioDir.path}/$ayahNumber.mp3';
  }
}
