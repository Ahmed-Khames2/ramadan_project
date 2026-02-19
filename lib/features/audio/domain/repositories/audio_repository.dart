import 'package:just_audio/just_audio.dart';
import 'package:ramadan_project/features/audio/domain/entities/reciter.dart';

abstract class AudioRepository {
  Future<void> playAyah(int ayahNumber, Reciter reciter);
  Future<void> playRange(List<int> ayahNumbers, Reciter reciter);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> setReciter(Reciter reciter);
  Future<Reciter> getSavedReciter();

  // Stream for playback state
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  Stream<bool> get isPlayingStream;
  Stream<PlayerState> get playerStateStream; // Added to track processing states
  Stream<int?> get currentAyahStream; // Which ayah is currently playing

  // Download methods
  Future<void> downloadAyah(int ayahNumber, Reciter reciter);
  Future<bool> isAyahDownloaded(int ayahNumber, Reciter reciter);
  Future<void> cancelDownload(int ayahNumber);
  Stream<double> getDownloadProgress(int ayahNumber);
  Stream<Map<int, double>> get downloadProgressStream;
}
