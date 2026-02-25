import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../cubits/hadith_books_cubit.dart';
import 'hadith_chapters_page.dart';

class HadithBooksPage extends StatefulWidget {
  const HadithBooksPage({super.key});

  @override
  State<HadithBooksPage> createState() => _HadithBooksPageState();
}

class _HadithBooksPageState extends State<HadithBooksPage> {
  @override
  void initState() {
    super.initState();
    context.read<HadithBooksCubit>().loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المكتبة الإسلامية')),
      body: DecorativeBackground(
        child: BlocBuilder<HadithBooksCubit, HadithBooksState>(
          builder: (context, state) {
            if (state is HadithBooksLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HadithBooksLoaded) {
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
                            context.read<HadithBooksCubit>().loadBooks(),
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
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing6,
                  vertical: AppTheme.spacing4,
                ),
                itemCount: state.books.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppTheme.spacing6),
                itemBuilder: (context, index) {
                  final book = state.books[index];
                  return _BookCard(
                    title: book.nameArabic,
                    author: book.authorArabic,
                    bookKey: book.key,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HadithChaptersPage(book: book),
                        ),
                      );
                    },
                  );
                },
              );
            } else if (state is HadithBooksError) {
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
  final String author;
  final String bookKey;
  final VoidCallback onTap;

  const _BookCard({
    required this.title,
    required this.author,
    required this.bookKey,
    required this.onTap,
  });

  Color _getBookColor() {
    final hash = bookKey.hashCode.abs();
    final colors = [
      const Color(0xFF166534), // Deep Green
      const Color(0xFF1E3A8A), // Deep Blue
      const Color(0xFF7C2D12), // Terracotta
      const Color(0xFF334155), // Slate
      const Color(0xFF581C87), // Purple
      const Color(0xFF711F1F), // Burgundy
    ];
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bookColor = _getBookColor();

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          height: 160,
          child: Stack(
            children: [
              // Bottom Shadow for 3D effect
              Positioned(
                bottom: 5,
                left: 10,
                right: 5,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              // Main Book Body
              Container(
                decoration: BoxDecoration(
                  color: bookColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(5, 5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Book Spine (The side of the book)
                    Container(
                      width: 40,
                      decoration: BoxDecoration(
                        color: bookColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.1),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 100,
                            width: 2,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          const SizedBox(height: 10),
                          // Decorative gold bands on spine
                          _buildSpineBand(),
                          const Spacer(),
                          _buildSpineBand(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    // Book Cover
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacing4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.1),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Gold Border Frame
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppTheme.accentGold.withValues(
                                      alpha: 0.4,
                                    ),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(
                                  AppTheme.spacing2,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.bold,
                                        fontSize: title.length > 20 ? 18 : 22,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.5,
                                            ),
                                            offset: const Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacing2),
                                    Container(
                                      height: 1,
                                      width: 40,
                                      color: AppTheme.accentGold.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacing2),
                                    Text(
                                      author,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing1),
                            // Footer info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  'تصفح الآن',
                                  style: TextStyle(
                                    color: AppTheme.accentGold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.menu_book,
                                  size: 14,
                                  color: AppTheme.accentGold.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Page Edges (The white part of the pages)
                    Container(
                      width: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE68A), // Cream color for pages
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.4),
                            Colors.black.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpineBand() {
    return Container(
      height: 3,
      width: 25,
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 1, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}
