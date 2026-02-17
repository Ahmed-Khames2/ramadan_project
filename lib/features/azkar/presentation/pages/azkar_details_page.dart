import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'dart:async';

import 'package:ramadan_project/features/azkar/data/models/azkar_model.dart';
import 'package:ramadan_project/features/azkar/presentation/bloc/azkar_bloc.dart';

class AzkarDetailsPage extends StatefulWidget {
  final AzkarItem azkarItem;
  const AzkarDetailsPage({super.key, required this.azkarItem});

  @override
  State<AzkarDetailsPage> createState() => _AzkarDetailsPageState();
}

class _AzkarDetailsPageState extends State<AzkarDetailsPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _canTap = true;

  void _handleTap(ZekrModel zekr, int currentProgress) {
    if (!_canTap) return;

    if (currentProgress < zekr.repeat) {
      HapticFeedback.lightImpact();
      context.read<AzkarBloc>().add(
        TapZekr(zekrId: zekr.id, maxRepeat: zekr.repeat),
      );

      // Debounce to prevent accidental double clicks
      setState(() => _canTap = false);
      Timer(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _canTap = true);
      });

      // Auto-next logic: when zekr is finished
      if (currentProgress + 1 == zekr.repeat) {
        if (_currentIndex < widget.azkarItem.azkarTexts.length - 1) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          final currentZekr = widget.azkarItem.azkarTexts[_currentIndex];
          final currentCount =
              context.read<AzkarBloc>().state.progress[currentZekr.id] ?? 0;
          _handleTap(currentZekr, currentCount);
        },
        behavior: HitTestBehavior.opaque,
        child: DecorativeBackground(
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildProgressBar(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.azkarItem.azkarTexts.length,
                    onPageChanged: (index) =>
                        setState(() => _currentIndex = index),
                    itemBuilder: (context, index) {
                      final zekr = widget.azkarItem.azkarTexts[index];
                      return _buildZekrContent(context, zekr);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppTheme.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              widget.azkarItem.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryEmerald,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textDark),
            onPressed: () {
              context.read<AzkarBloc>().add(
                ResetCategoryProgress(widget.azkarItem.azkarTexts),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final total = widget.azkarItem.azkarTexts.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primaryEmerald.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                height: 8,
                width:
                    MediaQuery.of(context).size.width *
                    ((_currentIndex + 1) / total),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryEmerald, AppTheme.accentGold],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryEmerald.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التقدم: ${((_currentIndex + 1) / total * 100).toInt()}%',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_currentIndex + 1} / $total',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZekrContent(BuildContext context, ZekrModel zekr) {
    return BlocBuilder<AzkarBloc, AzkarState>(
      builder: (context, state) {
        final currentCount = state.progress[zekr.id] ?? 0;
        final isCompleted = currentCount >= zekr.repeat;

        return Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        zekr.text,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 26, // Larger font for full screen
                          height: 1.6,
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (zekr.source?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            zekr.source!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: AppTheme.textGrey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 100), // Space for bottom counter
                    ],
                  ),
                ),
              ),
            ),
            // Floating Counter Indicator at the bottom
            Container(
              padding: const EdgeInsets.only(bottom: 30),
              child: _buildCircularIndicator(zekr, currentCount, isCompleted),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCircularIndicator(
    ZekrModel zekr,
    int currentCount,
    bool isCompleted,
  ) {
    final progress = currentCount / zekr.repeat;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Glow
        if (isCompleted)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryEmerald.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: AppTheme.textGrey.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? AppTheme.primaryEmerald : AppTheme.accentGold,
            ),
            strokeCap: StrokeCap.round,
          ),
        ),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppTheme.primaryEmerald : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 30)
                : Text(
                    '${zekr.repeat - currentCount}',
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryEmerald,
                      height: 1.1,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
