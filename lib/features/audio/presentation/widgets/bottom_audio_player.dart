import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/features/audio/presentation/bloc/audio_bloc.dart';

class BottomAudioPlayer extends StatelessWidget {
  const BottomAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AudioBloc, AudioState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.currentAyah != current.currentAyah ||
          previous.selectedReciter != current.selectedReciter ||
          previous.position != current.position ||
          previous.duration != current.duration,
      builder: (context, state) {
        // Only show if playing or paused (i.e., audio session active)
        // If initial or stop, hide it? Or maybe always show if user selected a reciter?
        // Let's show it if available.
        if (state.status == AudioStatus.initial && state.currentAyah == null) {
          return const SizedBox.shrink();
        }

        final isPlaying = state.status == AudioStatus.playing;
        final isBuffering = state.status == AudioStatus.loading;

        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surface
                : theme.colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
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
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white24,
                    child: Icon(
                      Icons.person,
                      color: isDark ? theme.colorScheme.primary : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.selectedReciter.arabicName,
                          style: TextStyle(
                            color: isDark
                                ? theme.colorScheme.onSurface
                                : Colors.white,
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
                          style: TextStyle(
                            color: isDark
                                ? theme.colorScheme.onSurface.withOpacity(0.6)
                                : Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Controls
                  IconButton(
                    onPressed: () {
                      context.read<AudioBloc>().add(
                        AudioSeek(state.position - const Duration(seconds: 10)),
                      );
                    },
                    icon: Icon(
                      Icons.replay_10,
                      color: isDark
                          ? theme.colorScheme.onSurface
                          : Colors.white,
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? theme.colorScheme.primary : Colors.white,
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
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark
                                    ? Colors.white
                                    : theme.colorScheme.primary,
                              ),
                            )
                          : Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: isDark
                                  ? Colors.white
                                  : theme.colorScheme.primary,
                            ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      context.read<AudioBloc>().add(
                        AudioSeek(state.position + const Duration(seconds: 10)),
                      );
                    },
                    icon: Icon(
                      Icons.forward_10,
                      color: isDark
                          ? theme.colorScheme.onSurface
                          : Colors.white,
                    ),
                  ),
                ],
              ),
              if (state.duration > Duration.zero) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value:
                      state.position.inMilliseconds /
                      state.duration.inMilliseconds.clamp(1, double.infinity),
                  backgroundColor: isDark
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? theme.colorScheme.primary : Colors.white,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
