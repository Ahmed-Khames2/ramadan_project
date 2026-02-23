import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/hadith_cubit.dart';
import '../widgets/hadith_card.dart';
import 'hadith_details_page.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';

class HadithListPage extends StatefulWidget {
  const HadithListPage({super.key});

  @override
  State<HadithListPage> createState() => _HadithListPageState();
}

class _HadithListPageState extends State<HadithListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<HadithCubit>().loadHadiths();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأربعين النووية'),
        backgroundColor:
            AppTheme.primaryEmerald, // Added for consistent AppBar color
      ),
      body: DecorativeBackground(
        child: Column(
          children: [
            // Search Section matching other pages
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacing4,
                AppTheme.spacing2,
                AppTheme.spacing4,
                AppTheme.spacing4,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.primaryEmerald,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.spacing8),
                  bottomRight: Radius.circular(AppTheme.spacing8),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<HadithCubit>().searchHadiths(value);
                  setState(() {}); // Rebuild to update suffixIcon visibility
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'ابحث عن حديث...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.accentGold,
                  ),
                  fillColor: Colors.white.withOpacity(0.1),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            context.read<HadithCubit>().searchHadiths('');
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            const OrnamentalDivider(),
            const SizedBox(height: AppTheme.spacing4),
            Expanded(
              child: BlocBuilder<HadithCubit, HadithState>(
                builder: (context, state) {
                  if (state is HadithLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryEmerald,
                      ),
                    );
                  } else if (state is HadithLoaded) {
                    final hadiths = state.filteredHadiths;
                    if (hadiths.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 80,
                              color: theme.colorScheme.secondary.withOpacity(
                                0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text('لم يتم العثور على أحاديث'),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                      physics: const BouncingScrollPhysics(),
                      itemCount: hadiths.length,
                      itemBuilder: (context, index) {
                        return HadithCard(
                          hadith: hadiths[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HadithDetailsPage(hadith: hadiths[index]),
                              ),
                            );
                          },
                        );
                      },
                    );
                  } else if (state is HadithError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
