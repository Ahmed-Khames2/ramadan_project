import 'dart:math' show pi, cos, sin;
import 'package:flutter/material.dart';

import 'package:ramadan_project/core/theme/app_theme.dart';

class QiblaArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // Shadow
    final shadowPath = Path();
    shadowPath.moveTo(center.dx, center.dy - 70);
    shadowPath.lineTo(center.dx - 22, center.dy + 45);
    shadowPath.lineTo(center.dx, center.dy + 28);
    shadowPath.lineTo(center.dx + 22, center.dy + 45);
    shadowPath.close();

    paint.color = Colors.black.withOpacity(0.15);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(shadowPath, paint);

    // Main arrow
    final arrowPath = Path();
    arrowPath.moveTo(center.dx, center.dy - 75);
    arrowPath.lineTo(center.dx - 20, center.dy + 40);
    arrowPath.lineTo(center.dx, center.dy + 23);
    arrowPath.lineTo(center.dx + 20, center.dy + 40);
    arrowPath.close();

    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFFD700),
        AppTheme.accentGold,
        const Color(0xFFB8860B),
      ],
    ).createShader(Rect.fromCircle(center: center, radius: 75));
    paint.maskFilter = null;
    canvas.drawPath(arrowPath, paint);

    // Outline
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.5;
    paint.color = const Color(0xFFB8860B);
    canvas.drawPath(arrowPath, paint);

    // Highlight
    final highlightPath = Path();
    highlightPath.moveTo(center.dx, center.dy - 75);
    highlightPath.lineTo(center.dx - 7, center.dy - 25);
    highlightPath.lineTo(center.dx, center.dy + 23);
    highlightPath.close();

    paint.style = PaintingStyle.fill;
    paint.color = Colors.white.withOpacity(0.35);
    canvas.drawPath(highlightPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
