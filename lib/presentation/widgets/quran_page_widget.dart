import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/audio/presentation/bloc/audio_bloc.dart';
import 'package:ramadan_project/features/audio/presentation/widgets/ayah_audio_control.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';
import 'verse_ornament.dart';

class QuranPageWidget extends StatelessWidget {
  final int pageNumber;
  final List<Ayah> ayahs;
  final Function(Ayah ayah)? onAyahTap;

  const QuranPageWidget({
    super.key,
    required this.pageNumber,
    required this.ayahs,
    this.onAyahTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 1,
                  width: 40,
                  color:
                      (isDark
                              ? theme.colorScheme.secondary
                              : const Color(0xFFC5A059))
                          .withOpacity(0.5),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'الصفحة $pageNumber',
                    style: TextStyle(
                      fontFamily: 'UthmanTaha',
                      fontSize: 14,
                      color: isDark
                          ? theme.colorScheme.secondary
                          : const Color(0xFF1B5E20),
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  width: 40,
                  color:
                      (isDark
                              ? theme.colorScheme.secondary
                              : const Color(0xFFC5A059))
                          .withOpacity(0.5),
                ),
              ],
            ),
          ),

          // Ayah List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: ayahs.length,
              separatorBuilder: (context, index) => Divider(
                height: 32,
                thickness: 0.5,
                color: isDark ? Colors.white.withOpacity(0.1) : null,
              ),
              itemBuilder: (context, index) {
                final ayah = ayahs[index];
                return _buildAyahItem(context, ayah);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahItem(BuildContext context, Ayah ayah) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AudioBloc, AudioState>(
      buildWhen: (previous, current) =>
          previous.currentAyah == ayah.globalAyahNumber ||
          current.currentAyah == ayah.globalAyahNumber,
      builder: (context, state) {
        final isPlaying = state.currentAyah == ayah.globalAyahNumber;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: isPlaying
              ? BoxDecoration(
                  color: isDark
                      ? AppTheme.primaryEmerald.withOpacity(0.15)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryEmerald.withOpacity(0.3),
                  ),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ayah Text
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  ayah.text,
                  style: TextStyle(
                    fontFamily: 'UthmanTaha',
                    fontSize: 22,
                    height: 1.8,
                    color: isDark
                        ? theme.colorScheme.onSurface
                        : const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),

              const SizedBox(height: 16),

              // Controls Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  VerseOrnament(
                    ayahNumber: ayah.ayahNumber,
                    size: 28,
                    color: isPlaying
                        ? AppTheme.primaryEmerald
                        : (isDark
                              ? theme.colorScheme.secondary
                              : const Color(0xFFC5A059)),
                  ),

                  const Expanded(child: SizedBox()), // Spacer
                  // Audio Control
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? theme.colorScheme.surface : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "استماع",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? theme.colorScheme.onSurface.withOpacity(0.6)
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: AyahAudioControl(
                            ayahNumber: ayah.globalAyahNumber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
