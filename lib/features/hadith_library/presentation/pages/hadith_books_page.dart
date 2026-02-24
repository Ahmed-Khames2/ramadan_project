import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../cubits/hadith_library_cubit.dart';
import 'hadith_chapters_page.dart';
import 'hadith_search_page.dart';

class HadithBooksPage extends StatefulWidget {
  const HadithBooksPage({super.key});

  @override
  State<HadithBooksPage> createState() => _HadithBooksPageState();
}

class _HadithBooksPageState extends State<HadithBooksPage> {
  @override
  void initState() {
    super.initState();
    context.read<HadithLibraryCubit>().loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المكتبة الإسلامية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HadithSearchPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: DecorativeBackground(
        child: BlocBuilder<HadithLibraryCubit, HadithLibraryState>(
          builder: (context, state) {
            if (state is HadithLibraryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HadithLibraryBooksLoaded) {
              if (state.books.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.database,
                        size: 64,
                        color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      const Text(
                        'جاري تجهيز المكتبة لأول مرة...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing2),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing8,
                        ),
                        child: Text(
                          'يتم الآن فهرسة أكثر من 85 ألف حديث في الخلفية. يرجى الانتظار قليلاً ثم المحاولة مرة أخرى.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing6),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<HadithLibraryCubit>().loadBooks(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('تحديث'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryEmerald,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing6,
                            vertical: AppTheme.spacing3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusM,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(AppTheme.spacing4),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppTheme.spacing4,
                    mainAxisSpacing: AppTheme.spacing4,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: state.books.length,
                  itemBuilder: (context, index) {
                    final book = state.books[index];
                    return _BookCard(
                      title: book.nameArabic,
                      subtitle: book.authorArabic,
                      icon: FontAwesomeIcons.bookOpen,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HadithChaptersPage(book: book),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            } else if (state is HadithLibraryError) {
              return Center(child: Text('خطأ: ${state.message}'));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _BookCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              decoration: BoxDecoration(
                color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: FaIcon(icon, color: AppTheme.primaryEmerald, size: 32),
            ),
            const SizedBox(height: AppTheme.spacing3),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing2,
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing1),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing2,
              ),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
