import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/features/audio/presentation/bloc/audio_bloc.dart';

class AyahAudioControl extends StatelessWidget {
  final int ayahNumber;

  const AyahAudioControl({super.key, required this.ayahNumber});

  @override
  Widget build(BuildContext context) {
    // DEBUG LOG: Remove before production
    // print('AyahAudioControl: Building for ayah $ayahNumber');

    return BlocBuilder<AudioBloc, AudioState>(
      buildWhen: (previous, current) {
        // Rebuild if this ayah is changing stat
        return previous.currentAyah == ayahNumber ||
            current.currentAyah == ayahNumber ||
            previous.downloadProgress[ayahNumber] !=
                current.downloadProgress[ayahNumber];
      },
      builder: (context, state) {
        final isPlaying =
            state.currentAyah == ayahNumber &&
            state.status == AudioStatus.playing;
        final isBuffering =
            state.currentAyah == ayahNumber &&
            state.status == AudioStatus.loading;
        final downloadProgress = state.downloadProgress[ayahNumber];

        // DEBUG LOG
        // if (isPlaying) print('AyahAudioControl: $ayahNumber IS PLAYING');

        // This check needs to be async or derived from state.
        // We don't have isDownloaded in state map yet, only progress.
        // We can add "downloaded" set to state or check repository.
        // For UI simplicity play/pause is primary. Download is secondary action.

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Play/Pause Button
            // Play/Pause Button
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  print('AyahAudioControl: Pressed $ayahNumber'); // DEBUG LOG
                  if (isPlaying) {
                    context.read<AudioBloc>().add(AudioPause());
                  } else if (state.currentAyah == ayahNumber &&
                      state.status == AudioStatus.paused) {
                    context.read<AudioBloc>().add(AudioResume());
                  } else {
                    context.read<AudioBloc>().add(AudioPlayAyah(ayahNumber));
                  }
                },
                icon: isBuffering
                    ? const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: isPlaying
                            ? const Color(0xFF1B5E20)
                            : const Color(0xFFC5A059),
                        size: 28,
                      ),
              ),
            ),

            // Download Button (Optional based on design)
            // Download Button (Visible only if not playing to save space, or always?)
            // Let's keep it minimal. Only show if downloading.
            if (downloadProgress != null && downloadProgress < 1.0)
              SizedBox(
                width: 24,
                height: 24,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CircularProgressIndicator(
                    value: downloadProgress,
                    strokeWidth: 2,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              )
            else if (!isPlaying) // Hide download if playing to reduce clutter?
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    context.read<AudioBloc>().add(
                      AudioDownloadAyah(ayahNumber),
                    );
                  },
                  icon: const Icon(
                    Icons.download_rounded,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
