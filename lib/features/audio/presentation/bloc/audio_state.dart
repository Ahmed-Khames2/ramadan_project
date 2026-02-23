part of 'audio_bloc.dart';

enum AudioStatus { initial, loading, playing, paused, error }

class AudioState extends Equatable {
  final AudioStatus status;
  final int? currentAyah;
  final int? lastAyah;
  final Reciter selectedReciter;
  final Duration position;
  final Duration duration;
  final String? errorMessage;
  final Map<int, double> downloadProgress;
  final bool repeatOne;
  final bool isOptimistic;
  final List<int>? currentRange;

  const AudioState({
    this.status = AudioStatus.initial,
    this.currentAyah,
    this.lastAyah,
    this.selectedReciter = Reciters.defaultReciter,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage,
    this.downloadProgress = const {},
    this.repeatOne = false,
    this.isOptimistic = false,
    this.currentRange,
  });

  AudioState copyWith({
    AudioStatus? status,
    int? currentAyah,
    int? lastAyah,
    Reciter? selectedReciter,
    Duration? position,
    Duration? duration,
    String? errorMessage,
    Map<int, double>? downloadProgress,
    bool? repeatOne,
    bool? isOptimistic,
    List<int>? currentRange,
  }) {
    // Standard copyWith pattern
    return AudioState(
      status: status ?? this.status,
      currentAyah: currentAyah ?? this.currentAyah,
      lastAyah: lastAyah ?? this.lastAyah,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      repeatOne: repeatOne ?? this.repeatOne,
      isOptimistic: isOptimistic ?? this.isOptimistic,
      currentRange: currentRange ?? this.currentRange,
    );
  }

  // Specific copyWith for nullable fields to allow setting them to null
  AudioState copyWithNullable({
    AudioStatus? status,
    int? Function()? currentAyah,
    int? Function()? lastAyah,
    Reciter? selectedReciter,
    Duration? position,
    Duration? duration,
    String? errorMessage,
    Map<int, double>? downloadProgress,
    bool? repeatOne,
    bool? isOptimistic,
    List<int>? Function()? currentRange,
  }) {
    return AudioState(
      status: status ?? this.status,
      currentAyah: currentAyah != null ? currentAyah() : this.currentAyah,
      lastAyah: lastAyah != null ? lastAyah() : this.lastAyah,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      repeatOne: repeatOne ?? this.repeatOne,
      isOptimistic: isOptimistic ?? this.isOptimistic,
      currentRange: currentRange != null ? currentRange() : this.currentRange,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentAyah,
    lastAyah,
    selectedReciter,
    position,
    duration,
    errorMessage,
    downloadProgress,
    repeatOne,
    isOptimistic,
    currentRange,
  ];
}
