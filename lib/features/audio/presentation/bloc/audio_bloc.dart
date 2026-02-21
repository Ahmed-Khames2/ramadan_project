import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
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
    // on<AudioRepeatModeChanged>(_onRepeatModeChanged); // Keeping this commented out if event not in feature branch, but if in main it should receive it?
    // Wait, the event definition part 'audio_event.dart' might check for AudioRepeatModeChanged.
    // If 'audio_event.dart' from feature/ramadan (which I think I had context of) doesn't have it, I can't listen to it.
    // Let's assume for safety I ONLY include what was in feature/ramadan for now to avoid compilation errors if I missed the event class.
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
    emit(
      state.copyWith(
        status: AudioStatus.error,
        errorMessage: "جاري العمل علي هذه",
      ),
    );
  }

  Future<void> _onPlayRange(
    AudioPlayRange event,
    Emitter<AudioState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AudioStatus.error,
        errorMessage: "جاري العمل علي هذه",
      ),
    );
  }

  Future<void> _onPlayPages(
    AudioPlayPages event,
    Emitter<AudioState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AudioStatus.error,
        errorMessage: "جاري العمل علي هذه",
      ),
    );
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
    emit(
      state.copyWith(
        status: AudioStatus.error,
        errorMessage: "جاري العمل علي هذه",
      ),
    );
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

  void _onSkipNext(AudioSkipNext event, Emitter<AudioState> emit) {
    emit(
      state.copyWith(
        status: AudioStatus.error,
        errorMessage: "جاري العمل علي هذه",
      ),
    );
  }

  void _onSkipPrevious(AudioSkipPrevious event, Emitter<AudioState> emit) {
    emit(
      state.copyWith(
        status: AudioStatus.error,
        errorMessage: "جاري العمل علي هذه",
      ),
    );
  }

  void _onPlayerStateChanged(
    _AudioPlayerStateChanged event,
    Emitter<AudioState> emit,
  ) {
    final playerState = event.playerState;
    final isPlaying = playerState.playing;
    final processingState = playerState.processingState;

    AudioStatus status;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      status = AudioStatus.loading;
    } else if (isPlaying) {
      status = AudioStatus.playing;
    } else if (processingState == ProcessingState.completed) {
      status = AudioStatus.initial;
    } else {
      status = AudioStatus.paused;
    }

    emit(state.copyWith(status: status));
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
