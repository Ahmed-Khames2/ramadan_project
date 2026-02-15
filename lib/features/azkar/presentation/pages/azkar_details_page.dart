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
      body: DecorativeBackground(
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
                    return _buildZekrCard(context, zekr);
                  },
                ),
              ),
            ],
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
      child: Stack(
        children: [
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primaryEmerald.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 6,
            width:
                MediaQuery.of(context).size.width *
                ((_currentIndex + 1) / total),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryEmerald, AppTheme.accentGold],
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryEmerald.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZekrCard(BuildContext context, ZekrModel zekr) {
    return BlocBuilder<AzkarBloc, AzkarState>(
      builder: (context, state) {
        final currentCount = state.progress[zekr.id] ?? 0;
        final isCompleted = currentCount >= zekr.repeat;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryEmerald.withOpacity(0.08),
                        blurRadius: 40,
                        offset: const Offset(0, 15),
                      ),
                    ],
                    border: Border.all(
                      color: isCompleted
                          ? AppTheme.primaryEmerald
                          : AppTheme.accentGold.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Text(
                          zekr.text,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            color: AppTheme.textDark,
                            height: 1.8,
                          ),
                        ),
                        if (zekr.source?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.warmBeige.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              zekr.source!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: AppTheme.textGrey,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildCounterButton(zekr, currentCount, isCompleted),
              const SizedBox(height: 24),
              Text(
                'الذكر ${_currentIndex + 1} من ${widget.azkarItem.azkarTexts.length}',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textGrey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCounterButton(
    ZekrModel zekr,
    int currentCount,
    bool isCompleted,
  ) {
    return GestureDetector(
      onTap: () => _handleTap(zekr, currentCount),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: _canTap ? 1.0 : 0.95,
        child: Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppTheme.primaryEmerald : Colors.white,
            border: Border.all(color: AppTheme.primaryEmerald, width: 6),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryEmerald.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 50)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${zekr.repeat - currentCount}',
                        style: GoogleFonts.cairo(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryEmerald,
                        ),
                      ),
                      Text(
                        'متبقي',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: AppTheme.textGrey,
                          height: 0.8,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
