import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/hadith.dart';
import '../cubits/hadith_search_cubit.dart';
import 'hadith_detail_page.dart';

class HadithSearchPage extends StatefulWidget {
  const HadithSearchPage({super.key});

  @override
  State<HadithSearchPage> createState() => _HadithSearchPageState();
}

class _HadithSearchPageState extends State<HadithSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'بحث في الأحاديث...',
            border: InputBorder.none,
            hintStyle: const TextStyle(color: Colors.white70),
            suffixIcon: BlocBuilder<HadithSearchCubit, HadithSearchState>(
              builder: (context, state) {
                if (state is HadithSearchLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                    context.read<HadithSearchCubit>().search('');
                  },
                );
              },
            ),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (query) {
            context.read<HadithSearchCubit>().search(query);
          },
        ),
      ),
      body: DecorativeBackground(
        child: BlocBuilder<HadithSearchCubit, HadithSearchState>(
          builder: (context, state) {
            final List<Hadith> results = (state is HadithSearchLoaded)
                ? state.results
                : [];
            final bool isLoading = state is HadithSearchLoading;

            if (isLoading && results.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (results.isEmpty && state is HadithSearchLoaded) {
              return const Center(child: Text('لا توجد نتائج'));
            }

            if (state is HadithSearchInitial) {
              return const Center(child: Text('ابدأ البحث عن حديث'));
            }

            return Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacing4),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final hadith = results[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
                      child: ListTile(
                        title: Text(
                          hadith.textArabic,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Amiri'),
                        ),
                        subtitle: Text(
                          '${hadith.bookTitle} - ${hadith.chapterTitle}',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HadithDetailPage(hadith: hadith),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
