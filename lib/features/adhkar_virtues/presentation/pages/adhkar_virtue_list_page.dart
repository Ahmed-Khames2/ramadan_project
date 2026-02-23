import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/adhkar_virtue_cubit.dart';
import '../widgets/adhkar_virtue_card.dart';
import 'adhkar_virtue_details_page.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';

class AdhkarVirtueListPage extends StatefulWidget {
  const AdhkarVirtueListPage({super.key});

  @override
  State<AdhkarVirtueListPage> createState() => _AdhkarVirtueListPageState();
}

class _AdhkarVirtueListPageState extends State<AdhkarVirtueListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdhkarVirtueCubit>().loadAdhkar();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أذكار وفضائل')),
      body: DecorativeBackground(
        child: Column(
          children: [
            // Search & Categories Section
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: const BoxDecoration(
                color: AppTheme.primaryEmerald,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<AdhkarVirtueCubit>().searchAdhkar(value);
                      setState(() {});
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'ابحث في الأذكار والفضائل...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.accentGold,
                      ),
                      fillColor: Colors.white.withValues(alpha: 0.1),
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
                                context.read<AdhkarVirtueCubit>().searchAdhkar(
                                  '',
                                );
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category Tabs
                  BlocBuilder<AdhkarVirtueCubit, AdhkarVirtueState>(
                    builder: (context, state) {
                      final activeCategory = state is AdhkarVirtueLoaded
                          ? state.activeCategory
                          : 0;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildCategoryTab(
                              context,
                              'الكل',
                              0,
                              activeCategory,
                            ),
                            _buildCategoryTab(
                              context,
                              'أذكار الصباح',
                              1,
                              activeCategory,
                            ),
                            _buildCategoryTab(
                              context,
                              'أذكار المساء',
                              2,
                              activeCategory,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const OrnamentalDivider(),
            const SizedBox(height: 8),

            Expanded(
              child: BlocBuilder<AdhkarVirtueCubit, AdhkarVirtueState>(
                builder: (context, state) {
                  if (state is AdhkarVirtueLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryEmerald,
                      ),
                    );
                  } else if (state is AdhkarVirtueLoaded) {
                    final adhkar = state.filteredAdhkar;
                    if (adhkar.isEmpty) {
                      return const Center(
                        child: Text('لم يتم العثور على نتائج'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 32),
                      physics: const BouncingScrollPhysics(),
                      itemCount: adhkar.length,
                      itemBuilder: (context, index) {
                        return AdhkarVirtueCard(
                          adhk: adhkar[index],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AdhkarVirtueDetailsPage(adhk: adhkar[index]),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is AdhkarVirtueError) {
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

  Widget _buildCategoryTab(
    BuildContext context,
    String label,
    int index,
    int activeIndex,
  ) {
    final isActive = index == activeIndex;
    return GestureDetector(
      onTap: () => context.read<AdhkarVirtueCubit>().filterByCategory(index),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.accentGold
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black87 : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
