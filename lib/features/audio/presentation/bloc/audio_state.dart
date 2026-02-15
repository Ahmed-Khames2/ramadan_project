part of 'audio_bloc.dart';

enum AudioStatus { initial, loading, playing, paused, error }

class AudioState extends Equatable {
  final AudioStatus status;
  final int? currentAyah;
  final Reciter selectedReciter;
  final Duration position;
  final Duration duration;
  final String? errorMessage;
  final Map<int, double>
  downloadProgress; // Map of Ayah number to progress 0.0-1.0

  const AudioState({
    this.status = AudioStatus.initial,
    this.currentAyah,
    this.selectedReciter = Reciters.defaultReciter,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage,
    this.downloadProgress = const {},
  });

  AudioState copyWith({
    AudioStatus? status,
    int? currentAyah,
    Reciter? selectedReciter,
    Duration? position,
    Duration? duration,
    String? errorMessage,
    Map<int, double>? downloadProgress,
  }) {
    return AudioState(
      status: status ?? this.status,
      currentAyah:
          currentAyah, // Allow null to be passed? No, if passed as null it means clear it?
      // Actually copyWith semantics usually ignore null, so we need a way to clear it.
      // But for currentAyah, if we pass null explicitly we might want to clear it.
      // Let's use a sentinel or just handle it logic-side.
      // For now, if currentAyah is passed, we use it. If we want to clear, we might need a nullable wrapper.
      // But here: currentAyah ?? this.currentAyah means we can't clear it easily.
      // Let's assume we won't clear it via copyWith null, but passing a specific value.
      selectedReciter: selectedReciter ?? this.selectedReciter,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage:
          errorMessage, // Reset error message on copy normally? Or keep it?
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  // Specific copyWith for nullable fields
  AudioState copyWithNullable({
    AudioStatus? status,
    int? Function()? currentAyah, // Function that returns int?
    Reciter? selectedReciter,
    Duration? position,
    Duration? duration,
    String? errorMessage,
    Map<int, double>? downloadProgress,
  }) {
    return AudioState(
      status: status ?? this.status,
      currentAyah: currentAyah != null ? currentAyah() : this.currentAyah,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage: errorMessage,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentAyah,
    selectedReciter,
    position,
    duration,
    errorMessage,
    downloadProgress,
  ];
}
