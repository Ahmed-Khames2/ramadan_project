import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadan_project/core/constants/reciters.dart';
import 'package:ramadan_project/features/audio/domain/entities/reciter.dart';
import 'package:ramadan_project/features/audio/domain/repositories/audio_repository.dart';
import 'package:ramadan_project/features/audio/domain/repositories/reciter_repository.dart';

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
    on<_AudioCurrentAyahChanged>((event, emit) {
      // If we are in optimistic mode (just skipped), ignore all stream updates
      // until the player catches up to our targeted ayah.
      if (state.isOptimistic) {
        if (event.ayahNumber == state.currentAyah) {
          // Target reached! Clear flag and update state in one go.
          emit(
            state.copyWith(
              isOptimistic: false,
              currentAyah: event.ayahNumber,
              lastAyah: event.ayahNumber,
            ),
          );
        }
        // While optimistic, we block ALL other ayah changes from the stream
        // to prevent "jump back" flickers.
        return;
      }

      emit(
        state.copyWithNullable(
          currentAyah: () => event.ayahNumber,
          lastAyah: event.ayahNumber != null ? () => event.ayahNumber : null,
        ),
      );
    });
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
    _playerStateSubscription = _audioRepository.playerStateStream.listen(
      (playerState) => add(_AudioPlayerStateChanged(playerState)),
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
    try {
      emit(
        state.copyWithNullable(
          status: AudioStatus.loading,
          currentRange: () => null, // Playing single ayah clears range
        ),
      );
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
    try {
      emit(
        state.copyWith(
          status: AudioStatus.loading,
          currentRange: event.ayahNumbers,
          currentAyah: event.ayahNumbers.isNotEmpty
              ? event.ayahNumbers.first
              : null,
        ),
      );
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
    try {
      emit(state.copyWith(status: AudioStatus.loading));
      final List<int> ayahNumbers = [];
      for (int page = event.startPage; page <= event.endPage; page++) {
        final pageData = quran.getPageData(page);
        for (final data in pageData) {
          final surahNum = data['surah'] as int;
          final startAyah = data['start'] as int;
          final endAyah = data['end'] as int;
          for (int i = startAyah; i <= endAyah; i++) {
            ayahNumbers.add(_getGlobalAyahId(surahNum, i));
          }
        }
      }
      emit(state.copyWith(currentRange: ayahNumbers));
      await _audioRepository.playRange(ayahNumbers, state.selectedReciter);
    } catch (e) {
      emit(
        state.copyWith(status: AudioStatus.error, errorMessage: e.toString()),
      );
    }
  }

  int _getGlobalAyahId(int surahNum, int ayahNum) {
    int global = 0;
    for (int s = 1; s < surahNum; s++) {
      global += quran.getVerseCount(s);
    }
    return global + ayahNum;
  }

  Future<void> _onPause(AudioPause event, Emitter<AudioState> emit) async {
    await _audioRepository.pause();
  }

  Future<void> _onStop(AudioStop event, Emitter<AudioState> emit) async {
    await _audioRepository.stop();
  }

  Future<void> _onResume(AudioResume event, Emitter<AudioState> emit) async {
    if (state.status == AudioStatus.initial && state.lastAyah != null) {
      if (state.currentRange != null && state.currentRange!.isNotEmpty) {
        add(AudioPlayRange(state.currentRange!));
      } else {
        add(AudioPlayAyah(state.lastAyah!));
      }
    } else {
      await _audioRepository.resume();
    }
  }

  Future<void> _onSeek(AudioSeek event, Emitter<AudioState> emit) async {
    await _audioRepository.seek(event.position);
  }

  Future<void> _onReciterChanged(
    AudioReciterChanged event,
    Emitter<AudioState> emit,
  ) async {
    try {
      await _reciterRepository.saveReciter(event.reciter);
      emit(state.copyWith(selectedReciter: event.reciter));

      // If playing or loading, restart with new reciter while preserving current position
      if ((state.status == AudioStatus.playing ||
              state.status == AudioStatus.loading) &&
          state.currentAyah != null) {
        // Use isOptimistic to keep the highlight during transition
        emit(state.copyWith(isOptimistic: true, status: AudioStatus.loading));

        if (state.currentRange != null && state.currentRange!.isNotEmpty) {
          // Find where we are in the playlist and resume from there
          final currentIdx = state.currentRange!.indexOf(state.currentAyah!);
          if (currentIdx != -1) {
            final remainingRange = state.currentRange!.sublist(currentIdx);
            add(AudioPlayRange(remainingRange));
          } else {
            add(AudioPlayAyah(state.currentAyah!));
          }
        } else {
          add(AudioPlayAyah(state.currentAyah!));
        }
      }
    } catch (e) {
      emit(
        state.copyWith(status: AudioStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onDownloadAyah(
    AudioDownloadAyah event,
    Emitter<AudioState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AudioStatus.error,
        errorMessage: "جاري العمل علي هذه",
      ),
    );
  }

  Future<void> _onCancelDownload(
    AudioCancelDownload event,
    Emitter<AudioState> emit,
  ) async {
    await _audioRepository.cancelDownload(event.ayahNumber);
  }

  Future<void> _onSkipNext(
    AudioSkipNext event,
    Emitter<AudioState> emit,
  ) async {
    if (state.currentAyah != null) {
      final nextAyah = state.currentAyah! + 1;
      // Optimistic update for UI snapiness
      emit(
        state.copyWith(
          currentAyah: nextAyah,
          lastAyah: state.currentAyah, // Update lastAyah too
          status: AudioStatus.loading,
          isOptimistic: true,
        ),
      );

      // Use playlist seek if available
      final handled = await _audioRepository.seekToNext();
      if (!handled) {
        add(AudioPlayAyah(nextAyah));
      }
    }
  }

  Future<void> _onSkipPrevious(
    AudioSkipPrevious event,
    Emitter<AudioState> emit,
  ) async {
    if (state.currentAyah != null && state.currentAyah! > 1) {
      final prevAyah = state.currentAyah! - 1;
      // Optimistic update for UI snapiness
      emit(
        state.copyWith(
          currentAyah: prevAyah,
          lastAyah: state.currentAyah, // Update lastAyah too
          status: AudioStatus.loading,
          isOptimistic: true,
        ),
      );

      // Use playlist seek if available
      final handled = await _audioRepository.seekToPrevious();
      if (!handled) {
        add(AudioPlayAyah(prevAyah));
      }
    }
  }

  void _onPlayerStateChanged(
    _AudioPlayerStateChanged event,
    Emitter<AudioState> emit,
  ) {
    final playerState = event.playerState;
    final isPlaying = playerState.playing;
    final processingState = playerState.processingState;

    AudioStatus status;
    if (processingState == ProcessingState.completed) {
      status = AudioStatus.initial;
    } else if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      status = AudioStatus.loading;
    } else if (isPlaying) {
      status = AudioStatus.playing;
    } else {
      status = AudioStatus.paused;
    }

    emit(state.copyWith(status: status));
  }

  Future<void> _onRepeatModeChanged(
    AudioRepeatModeChanged event,
    Emitter<AudioState> emit,
  ) async {
    await _audioRepository.setLoopMode(event.repeatOne);
    emit(state.copyWith(repeatOne: event.repeatOne));
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
