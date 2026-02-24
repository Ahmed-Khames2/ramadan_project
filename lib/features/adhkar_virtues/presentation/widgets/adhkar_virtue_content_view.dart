import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/adhkar_virtue.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'zikr_counter_widget.dart';

/// A completely redesigned, immersive details page for Adhkar & Virtues.
/// Layout: Hero header with content text → counter (if applicable) →
///         flowing sections without separate containers.
class AdhkarVirtueContentView extends StatefulWidget {
  final AdhkarVirtue adhk;

  const AdhkarVirtueContentView({super.key, required this.adhk});

  @override
  State<AdhkarVirtueContentView> createState() =>
      _AdhkarVirtueContentViewState();
}

class _AdhkarVirtueContentViewState extends State<AdhkarVirtueContentView> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  bool _contentCopied = false;

  Color get _categoryColor {
    switch (widget.adhk.type) {
      case 1:
        return const Color(0xFFE65100); // Deep Orange - Morning
      case 2:
        return const Color(0xFF283593); // Deep Indigo - Evening
      default:
        return AppTheme.primaryEmerald; // Emerald - General
    }
  }

  String get _categoryLabel {
    switch (widget.adhk.type) {
      case 1:
        return 'أذكار الصباح';
      case 2:
        return 'أذكار المساء';
      default:
        return 'فضائل عامة';
    }
  }

  IconData get _categoryIcon {
    switch (widget.adhk.type) {
      case 1:
        return Icons.wb_sunny_rounded;
      case 2:
        return Icons.nightlight_round;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 400;
      if (show != _showScrollToTop) setState(() => _showScrollToTop = show);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _copyContent() {
    Clipboard.setData(ClipboardData(text: widget.adhk.content));
    HapticFeedback.lightImpact();
    setState(() => _contentCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _contentCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _categoryColor;
    final hasCounter = widget.adhk.count > 1;

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Hero Header ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildHeroHeader(context, isDark, color, hasCounter),
            ),

            // ── Counter Section ──────────────────────────────────────────
            if (hasCounter)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing4,
                  ),
                  child: ZikrCounterWidget(
                    targetCount: widget.adhk.count,
                    countDescription: widget.adhk.countDescription,
                    color: color,
                  ),
                ),
              ),

            // ── Flowing Info Sections ────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (widget.adhk.fadl.isNotEmpty)
                    _buildFlowingSection(
                      context,
                      isDark: isDark,
                      icon: Icons.stars_rounded,
                      title: 'الفضل والأجر',
                      content: widget.adhk.fadl,
                      accentColor: AppTheme.accentGold,
                    ),
                  if (widget.adhk.hadithText.isNotEmpty)
                    _buildFlowingSection(
                      context,
                      isDark: isDark,
                      icon: Icons.menu_book_rounded,
                      title: 'نص الحديث',
                      content: widget.adhk.hadithText,
                      accentColor: Colors.teal,
                      isQuote: true,
                    ),
                  if (widget.adhk.vocabularyExplanation.isNotEmpty)
                    _buildFlowingSection(
                      context,
                      isDark: isDark,
                      icon: Icons.translate_rounded,
                      title: 'معاني المفردات',
                      content: widget.adhk.vocabularyExplanation,
                      accentColor: Colors.brown.withValues(alpha: 0.8),
                    ),
                  if (widget.adhk.source.isNotEmpty)
                    _buildSourceBadge(context, isDark),
                ]),
              ),
            ),
          ],
        ),

        // ── Scroll to Top ─────────────────────────────────────────────────
        if (_showScrollToTop)
          Positioned(
            bottom: 24,
            left: 16,
            child: FloatingActionButton.small(
              heroTag: 'adhkar_scroll_top',
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
              backgroundColor: color,
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  // ── Hero Header with content text ────────────────────────────────────────
  Widget _buildHeroHeader(
    BuildContext context,
    bool isDark,
    Color color,
    bool hasCounter,
  ) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [color.withValues(alpha: 0.3), color.withValues(alpha: 0.05)]
              : [color.withValues(alpha: 0.12), color.withValues(alpha: 0.02)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(color: color.withValues(alpha: 0.15), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_categoryIcon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    _categoryLabel,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ─ Content Text (the main zikr) ─
              Text(
                widget.adhk.content,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 22,
                  height: 2.0,
                  fontFamily: 'UthmanTaha',
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 20),

              // ─ Copy button ─
              Center(
                child: GestureDetector(
                  onTap: _copyContent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _contentCopied
                          ? color.withValues(alpha: 0.15)
                          : color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: color.withValues(
                          alpha: _contentCopied ? 0.5 : 0.2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _contentCopied
                              ? Icons.check_circle_outline_rounded
                              : Icons.copy_rounded,
                          size: 18,
                          color: color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _contentCopied ? 'تم النسخ' : 'نسخ الذكر',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Flowing text section (no separate box, just a labeled paragraph) ─────
  Widget _buildFlowingSection(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String title,
    required String content,
    required Color accentColor,
    bool isQuote = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section label
          Row(
            children: [
              Container(
                width: 3,
                height: 20,
                margin: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Icon(icon, color: accentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          isQuote
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isDark ? 0.08 : 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      right: BorderSide(color: accentColor, width: 3),
                    ),
                  ),
                  child: Text(
                    content,
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      height: 1.8,
                      fontFamily: 'Cairo',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : Text(
                  content,
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    height: 1.8,
                    fontFamily: 'Cairo',
                  ),
                ),

          // Subtle divider
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Source badge ────────────────────────────────────────────────────────
  Widget _buildSourceBadge(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 6),
          Text(
            'المصدر: ',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 12,
              fontFamily: 'Cairo',
            ),
          ),
          Flexible(
            child: Text(
              widget.adhk.source,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 12,
                fontFamily: 'Cairo',
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
