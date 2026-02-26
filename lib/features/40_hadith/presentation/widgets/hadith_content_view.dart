import 'package:flutter/material.dart';
import '../../domain/entities/hadith.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'expandable_hadith_box.dart';

class HadithContentView extends StatefulWidget {
  final Hadith hadith;

  const HadithContentView({super.key, required this.hadith});

  @override
  State<HadithContentView> createState() => _HadithContentViewState();
}

class _HadithContentViewState extends State<HadithContentView> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 300 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTheme.spacing2),
              const OrnamentalDivider(),
              const SizedBox(height: AppTheme.spacing6),
              // Hadith Box
              ExpandableHadithBox(
                title: 'نص الحديث',
                content: widget.hadith.content,
                icon: Icons.menu_book_rounded,
                color: AppTheme.primaryEmerald,
              ),
              const SizedBox(height: AppTheme.spacing6),
              const OrnamentalDivider(),
              const SizedBox(height: AppTheme.spacing6),
              // Description Box
              ExpandableHadithBox(
                title: 'الشرح والفوائد',
                content: widget.hadith.description,
                icon: Icons.auto_awesome_rounded,
                color: AppTheme.accentGold,
              ),
              const SizedBox(height: AppTheme.spacing8),
            ],
          ),
        ),
        // Scroll to Top FAB
        if (_showScrollToTop)
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton.small(
              onPressed: _scrollToTop,
              backgroundColor: AppTheme.primaryEmerald,
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
