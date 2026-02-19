import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/features/audio/presentation/bloc/audio_bloc.dart';

class BottomAudioPlayer extends StatelessWidget {
  const BottomAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.currentAyah != current.currentAyah ||
          previous.selectedReciter != current.selectedReciter ||
          previous.position != current.position ||
          previous.duration != current.duration,
      builder: (context, state) {
        // Only show if playing or paused (i.e., audio session active)
        if (state.currentAyah == null) {
          return const SizedBox.shrink();
        }

        final isPlaying = state.status == AudioStatus.playing;
        final isBuffering = state.status == AudioStatus.loading;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1B5E20), // Deep emerald
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Reciter Info
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.selectedReciter.arabicName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          state.currentAyah != null
                              ? 'الآية ${state.currentAyah}'
                              : 'اختر آية للبدء',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Controls
                  IconButton(
                    onPressed: () {
                      context.read<AudioBloc>().add(const AudioSkipPrevious());
                    },
                    icon: const Icon(
                      Icons.skip_previous_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'الآية السابقة',
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (isPlaying) {
                          context.read<AudioBloc>().add(AudioPause());
                        } else {
                          if (state.currentAyah != null) {
                            context.read<AudioBloc>().add(AudioResume());
                          }
                        }
                      },
                      icon: isBuffering
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF1B5E20),
                              ),
                            )
                          : Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: const Color(0xFF1B5E20),
                            ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      context.read<AudioBloc>().add(const AudioSkipNext());
                    },
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'الآية التالية',
                  ),
                ],
              ),
              if (state.duration > Duration.zero) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value:
                      state.position.inMilliseconds /
                      state.duration.inMilliseconds.clamp(1, double.infinity),
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
