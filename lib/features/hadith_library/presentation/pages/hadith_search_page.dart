import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../cubits/hadith_library_cubit.dart';
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
          decoration: const InputDecoration(
            hintText: 'بحث في الأحاديث...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (query) {
            if (query.length > 2) {
              context.read<HadithLibraryCubit>().search(query);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          ),
        ],
      ),
      body: DecorativeBackground(
        child: BlocBuilder<HadithLibraryCubit, HadithLibraryState>(
          builder: (context, state) {
            if (state is HadithLibraryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HadithLibrarySearchResults) {
              if (state.results.isEmpty) {
                return const Center(child: Text('لا توجد نتائج'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppTheme.spacing4),
                itemCount: state.results.length,
                itemBuilder: (context, index) {
                  final hadith = state.results[index];
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
              );
            }
            return const Center(child: Text('ابدأ البحث عن حديث'));
          },
        ),
      ),
    );
  }
}
