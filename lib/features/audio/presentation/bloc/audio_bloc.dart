import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ramadan_project/core/constants/reciters.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadan_project/features/audio/domain/entities/reciter.dart';
import 'package:ramadan_project/features/audio/domain/repositories/audio_repository.dart';
import 'package:ramadan_project/features/audio/domain/repositories/reciter_repository.dart';

// Trigger analysis refresh

part 'audio_event.dart';
part 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioRepository _audioRepository;
  final ReciterRepository _reciterRepository;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _currentAyahSubscription;
  StreamSubscription? _downloadProgressSubscription;

  AudioBloc({
    required AudioRepository audioRepository,
    required ReciterRepository reciterRepository,
  }) : _audioRepository = audioRepository,
       _reciterRepository = reciterRepository,
       super(const AudioState()) {
    on<AudioStarted>(_onStarted);
    on<AudioPlayAyah>(_onPlayAyah);
    on<AudioPlayRange>(_onPlayRange);
    on<AudioPlayPages>(_onPlayPages);
    on<AudioPause>(_onPause);
    on<AudioStop>(_onStop);
    on<AudioResume>(_onResume);
    on<AudioSeek>(_onSeek);
    on<AudioReciterChanged>(_onReciterChanged);
    on<AudioDownloadAyah>(_onDownloadAyah);
    on<AudioRepeatModeChanged>(_onRepeatModeChanged);
    on<AudioSkipNext>(_onSkipNext);
    on<AudioSkipPrevious>(_onSkipPrevious);
    on<AudioCancelDownload>(_onCancelDownload);

    // Internal events
    on<_AudioPositionChanged>(
      (event, emit) => emit(state.copyWith(position: event.position)),
    );
    on<_AudioDurationChanged>(
      (event, emit) => emit(state.copyWith(duration: event.duration)),
    );
    on<_AudioPlayerStateChanged>(_onPlayerStateChanged);
    on<_AudioCurrentAyahChanged>(
      (event, emit) => emit(
        state.copyWithNullable(
          currentAyah: () => event.ayahNumber,
          lastAyah: event.ayahNumber != null ? () => event.ayahNumber : null,
        ),
      ),
    );
    on<_AudioDownloadProgressChanged>(
      (event, emit) => emit(state.copyWith(downloadProgress: event.progress)),
    );
  }

  Future<void> _onStarted(AudioStarted event, Emitter<AudioState> emit) async {
    // Load saved reciter
    final reciter = await _reciterRepository.getSavedReciter();
    emit(state.copyWith(selectedReciter: reciter));

    // Subscribe to streams
    _positionSubscription = _audioRepository.positionStream.listen(
      (pos) => add(_AudioPositionChanged(pos)),
    );
    _durationSubscription = _audioRepository.durationStream.listen(
      (dur) => add(_AudioDurationChanged(dur)),
    );
    _playerStateSubscription = _audioRepository.isPlayingStream.listen(
      (isPlaying) => add(_AudioPlayerStateChanged(isPlaying)),
    );
    _currentAyahSubscription = _audioRepository.currentAyahStream.listen(
      (ayah) => add(_AudioCurrentAyahChanged(ayah)),
    );
    _downloadProgressSubscription = _audioRepository.downloadProgressStream
        .listen((progress) => add(_AudioDownloadProgressChanged(progress)));
  }

  Future<void> _onPlayAyah(
    AudioPlayAyah event,
    Emitter<AudioState> emit,
  ) async {
    emit(state.copyWith(status: AudioStatus.loading, errorMessage: null));
    try {
      await _audioRepository.playAyah(event.ayahNumber, state.selectedReciter);
    } catch (e) {
      emit(
        state.copyWith(status: AudioStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onPlayRange(
    AudioPlayRange event,
    Emitter<AudioState> emit,
  ) async {
    emit(state.copyWith(status: AudioStatus.loading, errorMessage: null));
    try {
      await _audioRepository.playRange(
        event.ayahNumbers,
        state.selectedReciter,
      );
    } catch (e) {
      emit(
        state.copyWith(status: AudioStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onPlayPages(
    AudioPlayPages event,
    Emitter<AudioState> emit,
  ) async {
    final List<int> ayahNumbers = [];
    for (int p = event.startPage; p <= event.endPage; p++) {
      final pageVerses = quran.getPageData(p);
      for (final verse in pageVerses) {
        final surah = verse['surah'] as int;
        final ayah = verse['ayah'] as int;

        // Calculate global ayah number
        int global = 0;
        for (int s = 1; s < surah; s++) {
          global += quran.getVerseCount(s);
        }
        global += ayah;
        ayahNumbers.add(global);
      }
    }

    if (ayahNumbers.isNotEmpty) {
      add(AudioPlayRange(ayahNumbers));
    }
  }

  Future<void> _onPause(AudioPause event, Emitter<AudioState> emit) async {
    await _audioRepository.pause();
  }

  Future<void> _onStop(AudioStop event, Emitter<AudioState> emit) async {
    await _audioRepository.stop();
  }

  Future<void> _onResume(AudioResume event, Emitter<AudioState> emit) async {
    await _audioRepository.resume();
  }

  Future<void> _onSeek(AudioSeek event, Emitter<AudioState> emit) async {
    await _audioRepository.seek(event.position);
  }

  Future<void> _onReciterChanged(
    AudioReciterChanged event,
    Emitter<AudioState> emit,
  ) async {
    await _reciterRepository.saveReciter(event.reciter);
    emit(state.copyWith(selectedReciter: event.reciter));

    // If playing, restart with new reciter
    if (state.currentAyah != null && state.status == AudioStatus.playing) {
      add(AudioPlayAyah(state.currentAyah!));
    }
  }

  Future<void> _onDownloadAyah(
    AudioDownloadAyah event,
    Emitter<AudioState> emit,
  ) async {
    try {
      await _audioRepository.downloadAyah(
        event.ayahNumber,
        state.selectedReciter,
      );
    } catch (e) {
      // Errors handled in repo mostly, but if it throws we catch here
      emit(state.copyWith(errorMessage: "Download failed: $e"));
    }
  }

  Future<void> _onCancelDownload(
    AudioCancelDownload event,
    Emitter<AudioState> emit,
  ) async {
    await _audioRepository.cancelDownload(event.ayahNumber);
  }

  Future<void> _onRepeatModeChanged(
    AudioRepeatModeChanged event,
    Emitter<AudioState> emit,
  ) async {
    await _audioRepository.setLoopMode(event.repeatOne);
    emit(state.copyWith(repeatOne: event.repeatOne));
  }

  Future<void> _onSkipNext(
    AudioSkipNext event,
    Emitter<AudioState> emit,
  ) async {
    final effectiveAyah = state.currentAyah ?? state.lastAyah;
    if (effectiveAyah == null) return;

    // First try repository-level skip (playlists)
    final moved = await _audioRepository.seekToNext();

    // If it didn't move (likely single ayah mode), manually play next
    if (!moved && effectiveAyah < 6236) {
      add(AudioPlayAyah(effectiveAyah + 1));
    }
  }

  Future<void> _onSkipPrevious(
    AudioSkipPrevious event,
    Emitter<AudioState> emit,
  ) async {
    final effectiveAyah = state.currentAyah ?? state.lastAyah;
    if (effectiveAyah == null) return;

    // First try repository-level skip (playlists)
    final moved = await _audioRepository.seekToPrevious();

    // If it didn't move (likely single ayah mode), manually play previous
    if (!moved && effectiveAyah > 1) {
      add(AudioPlayAyah(effectiveAyah - 1));
    }
  }

  void _onPlayerStateChanged(
    _AudioPlayerStateChanged event,
    Emitter<AudioState> emit,
  ) {
    emit(
      state.copyWith(
        status: event.isPlaying ? AudioStatus.playing : AudioStatus.paused,
      ),
    );
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _currentAyahSubscription?.cancel();
    _downloadProgressSubscription?.cancel();
    return super.close();
  }
}
