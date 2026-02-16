import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import 'page_header_widget.dart';
import 'page_footer_widget.dart';

class MushafPageFrame extends StatelessWidget {
  final Widget child;
  final QuranPage page;

  const MushafPageFrame({super.key, required this.child, required this.page});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Inner Double Border
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.5),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Corner Ornaments
          _buildCorner(Alignment.topLeft, 0),
          _buildCorner(Alignment.topRight, 90),
          _buildCorner(Alignment.bottomRight, 180),
          _buildCorner(Alignment.bottomLeft, 270),

          // Main Content
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
                child: PageHeaderWidget(page: page),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: child,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: PageFooterWidget(pageNumber: page.pageNumber),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, double angle) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: RotationTransition(
          turns: AlwaysStoppedAnimation(angle / 360),
          child: SvgPicture.asset(
            'assets/images/frame_corner.svg',
            width: 40,
            height: 40,
            colorFilter: const ColorFilter.mode(
              Color(0xFFD4AF37),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
