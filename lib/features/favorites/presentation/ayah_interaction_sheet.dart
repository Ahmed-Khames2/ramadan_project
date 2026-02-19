import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quran/quran.dart' as quran;
import 'package:share_plus/share_plus.dart';
import 'package:ramadan_project/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';
import 'package:ramadan_project/features/khatmah/presentation/bloc/khatam_bloc.dart';

class AyahInteractionSheet extends StatelessWidget {
  final int surahNumber;
  final int ayahNumber;
  final int ayahId;

  const AyahInteractionSheet({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${quran.getSurahNameArabic(surahNumber)} : $ayahNumber',
                style: TextStyle(
                  fontFamily: 'UthmanTaha',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B5E20),
                ),
              ),
              BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, state) {
                  final isFavorite =
                      state is FavoritesLoaded &&
                      state.favorites.contains(ayahId);
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      context.read<FavoritesBloc>().add(
                        ToggleFavorite(
                          Ayah(
                            surahNumber: surahNumber,
                            ayahNumber: ayahNumber,
                            globalAyahNumber: ayahId,
                            text: quran.getVerse(surahNumber, ayahNumber),
                            pageNumber: quran.getPageNumber(
                              surahNumber,
                              ayahNumber,
                            ),
                            surahName: quran.getSurahNameArabic(surahNumber),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tafsir Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التفسير (الميسر)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<String>(
                  future: context.read<KhatamBloc>().quranRepository.getTafsir(
                    surahNumber,
                    ayahNumber,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: LinearProgressIndicator());
                    }
                    return Text(
                      snapshot.data ?? 'تعذر تحميل التفسير',
                      style: TextStyle(
                        fontFamily: 'UthmanTaha',
                        fontSize: 16,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final text = quran.getVerse(
                      surahNumber,
                      ayahNumber,
                      verseEndSymbol: true,
                    );
                    final shareText =
                        '$text\n\n[${quran.getSurahNameArabic(surahNumber)} : $ayahNumber]';
                    Share.share(shareText);
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('مشاركة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('إغلاق'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
