part of 'audio_bloc.dart';

abstract class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object?> get props => [];
}

class AudioStarted extends AudioEvent {
  const AudioStarted();
}

class AudioPlayAyah extends AudioEvent {
  final int ayahNumber;
  const AudioPlayAyah(this.ayahNumber);

  @override
  List<Object?> get props => [ayahNumber];
}

class AudioPlayRange extends AudioEvent {
  final List<int> ayahNumbers;
  const AudioPlayRange(this.ayahNumbers);

  @override
  List<Object?> get props => [ayahNumbers];
}

class AudioPlayPages extends AudioEvent {
  final int startPage;
  final int endPage;
  const AudioPlayPages(this.startPage, this.endPage);

  @override
  List<Object?> get props => [startPage, endPage];
}

class AudioPause extends AudioEvent {
  const AudioPause();
}

class AudioStop extends AudioEvent {
  const AudioStop();
}

class AudioResume extends AudioEvent {
  const AudioResume();
}

class AudioSeek extends AudioEvent {
  final Duration position;
  const AudioSeek(this.position);
  @override
  List<Object?> get props => [position];
}

class AudioReciterChanged extends AudioEvent {
  final Reciter reciter;
  const AudioReciterChanged(this.reciter);
  @override
  List<Object?> get props => [reciter];
}

class AudioDownloadAyah extends AudioEvent {
  final int ayahNumber;
  const AudioDownloadAyah(this.ayahNumber);
  @override
  List<Object?> get props => [ayahNumber];
}

class AudioCancelDownload extends AudioEvent {
  final int ayahNumber;
  const AudioCancelDownload(this.ayahNumber);
  @override
  List<Object?> get props => [ayahNumber];
}

// Internal events to update state from streams
class _AudioPositionChanged extends AudioEvent {
  final Duration position;
  const _AudioPositionChanged(this.position);
}

class _AudioDurationChanged extends AudioEvent {
  final Duration duration;
  const _AudioDurationChanged(this.duration);
}

class _AudioPlayerStateChanged extends AudioEvent {
  final bool isPlaying;
  const _AudioPlayerStateChanged(this.isPlaying);
}

class _AudioCurrentAyahChanged extends AudioEvent {
  final int? ayahNumber;
  const _AudioCurrentAyahChanged(this.ayahNumber);
}

class _AudioDownloadProgressChanged extends AudioEvent {
  final Map<int, double> progress;
  const _AudioDownloadProgressChanged(this.progress);
  @override
  List<Object?> get props => [progress];
}
