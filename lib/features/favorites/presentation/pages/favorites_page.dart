import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/features/favorites/domain/entities/favorite_ayah.dart';
import 'package:ramadan_project/features/quran/presentation/pages/mushaf_page_view.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:ramadan_project/features/favorites/data/repositories/favorites_repository.dart';
import 'package:ramadan_project/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';
import 'package:quran/quran.dart' as quran;

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final List<FavoriteAyah> favorites = state is FavoritesLoaded
            ? state.favorites
            : [];
        final bool isLoading = state is FavoritesLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'المفضلة',
              style: TextStyle(
                fontFamily: 'UthmanTaha',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: AppTheme.primaryEmerald,
            foregroundColor: Colors.white,
            actions: [
              if (favorites.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded),
                  onPressed: () => _showClearAllDialog(context),
                  tooltip: 'حذف الكل',
                ),
            ],
          ),
          body: DecorativeBackground(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryEmerald,
                    ),
                  )
                : favorites.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      return _buildFavoriteCard(favorites[index], context);
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 100,
            color: AppTheme.accentGold.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد آيات مفضلة',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryEmerald,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط مطولاً على أي آية لإضافتها للمفضلة',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(FavoriteAyah favorite, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: IslamicCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryEmerald.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.primaryEmerald.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 18,
                    color: AppTheme.primaryEmerald,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${favorite.surahName} • الآية ${favorite.ayahNumber}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryEmerald,
                    ),
                  ),
                ],
              ),
            ),

            // Ayah Text
            InkWell(
              onTap: () {
                final page = quran.getPageNumber(
                  favorite.surahNumber,
                  favorite.ayahNumber,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MushafPageView(initialPage: page),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  favorite.text,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'UthmanTaha',
                    fontSize: 20,
                    height: 1.8,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      context.read<FavoritesBloc>().add(
                        ToggleFavorite(
                          Ayah(
                            surahNumber: favorite.surahNumber,
                            ayahNumber: favorite.ayahNumber,
                            globalAyahNumber: favorite.globalAyahNumber,
                            text: favorite.text,
                            pageNumber: quran.getPageNumber(
                              favorite.surahNumber,
                              favorite.ayahNumber,
                            ),
                            surahName: favorite.surahName,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('حذف', style: TextStyle(fontSize: 13)),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      final page = quran.getPageNumber(
                        favorite.surahNumber,
                        favorite.ayahNumber,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MushafPageView(initialPage: page),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text(
                      'اذهب للآية',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryEmerald,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'حذف الكل',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'هل تريد حذف جميع الآيات المفضلة؟',
          style: TextStyle(),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء', style: TextStyle()),
          ),
          TextButton(
            onPressed: () async {
              await context.read<FavoritesRepository>().clearAll();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                if (context.mounted) {
                  context.read<FavoritesBloc>().add(LoadFavorites());
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle()),
          ),
        ],
      ),
    );
  }
}
