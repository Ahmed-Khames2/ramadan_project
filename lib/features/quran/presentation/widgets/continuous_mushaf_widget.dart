import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'package:ramadan_project/features/quran/data/repositories/quran_repository_impl.dart';
import 'mushaf/mushaf_verse_body.dart';
import 'mushaf/mushaf_page_frame.dart';

class ContinuousMushafPageWidget extends StatefulWidget {
  final int pageNumber;
  final double fontScale;
  final VoidCallback? onShowControls;
  final VoidCallback? onHideControls;

  const ContinuousMushafPageWidget({
    super.key,
    required this.pageNumber,
    this.fontScale = 1.0,
    this.onShowControls,
    this.onHideControls,
  });

  @override
  State<ContinuousMushafPageWidget> createState() =>
      _ContinuousMushafPageWidgetState();
}

class _ContinuousMushafPageWidgetState
    extends State<ContinuousMushafPageWidget> {
  late Future<QuranPage> _pageData;
  QuranPage? _cachedPage;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(ContinuousMushafPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNumber != widget.pageNumber) {
      _cachedPage = null; // Reset cache on page change
      _loadData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    // Check if data is already available synchronously to avoid flicker
    final repo = context.read<QuranRepository>();
    if (repo is QuranRepositoryImpl) {
      final cached = repo.getPageSync(widget.pageNumber);
      if (cached != null) {
        setState(() {
          _cachedPage = cached;
        });
        return;
      }
    }
    _pageData = repo.getPage(widget.pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    // If we have cached data, render immediately without FutureBuilder
    if (_cachedPage != null) {
      return _buildPageContent(_cachedPage!, context);
    }

    return FutureBuilder<QuranPage>(
      future: _pageData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Try to show placeholder (frame with loader) instead of just loader
          final repo = context.read<QuranRepository>();
          if (repo is QuranRepositoryImpl) {
            final placeholder = repo.getPagePlaceholder(widget.pageNumber);
            if (placeholder != null) {
              return MushafPageFrame(
                page: placeholder,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
          }
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  "Error loading ayahs",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) return const SizedBox.shrink();

        return _buildPageContent(snapshot.data!, context);
      },
    );
  }

  Widget _buildPageContent(QuranPage page, BuildContext context) {
    final isDefaultScale = (widget.fontScale - 1.0).abs() < 0.01;
    final contentScale = isDefaultScale ? 1.0 : widget.fontScale;

    return MushafPageFrame(
      page: page,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 4,
        radius: const Radius.circular(10),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is UserScrollNotification) {
              if (notification.direction != ScrollDirection.idle) {
                widget.onHideControls?.call();
              }
            }
            return false;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            // السماح بالسكرول العمودي
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: MushafVerseBody(
                page: page,
                scale: contentScale,
                onShowControls: widget.onShowControls,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
