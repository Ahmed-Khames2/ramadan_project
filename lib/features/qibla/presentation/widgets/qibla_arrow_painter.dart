import 'dart:math' show pi, cos, sin;
import 'package:flutter/material.dart';

class QiblaArrowPainter extends CustomPainter {
  final Color activeColor;
  final Color inactiveColor;

  QiblaArrowPainter({required this.activeColor, required this.inactiveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    const int petals = 12;
    final double innerR = radius * 0.45;
    final double outerR = radius * 0.85;

    for (int i = 0; i < petals; i++) {
      final double angle = i * (2 * pi / petals) - pi / 2;
      final bool isActive = i == 0; // Top petal is the indicator

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = isActive ? activeColor.withOpacity(0.9) : inactiveColor;

      if (isActive) {
        // Active petal glow using theme color
        final glowPaint = Paint()
          ..color = activeColor.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

        canvas.drawCircle(
          Offset(
            center.dx + outerR * cos(angle),
            center.dy + outerR * sin(angle),
          ),
          25,
          glowPaint,
        );
      }

      final petalPath = Path();
      // Control points for the same lotus petal shape
      final double cpAngle1 = angle - (pi / (petals * 1.5));
      final double cpAngle2 = angle + (pi / (petals * 1.5));

      final double xStart = center.dx + innerR * cos(angle);
      final double yStart = center.dy + innerR * sin(angle);
      final double xEnd = center.dx + outerR * cos(angle);
      final double yEnd = center.dy + outerR * sin(angle);
      final double cp1x = center.dx + (outerR * 0.7) * cos(cpAngle1);
      final double cp1y = center.dy + (outerR * 0.7) * sin(cpAngle1);
      final double cp2x = center.dx + (outerR * 0.7) * cos(cpAngle2);
      final double cp2y = center.dy + (outerR * 0.7) * sin(cpAngle2);

      petalPath.moveTo(xStart, yStart);
      petalPath.quadraticBezierTo(cp1x, cp1y, xEnd, yEnd);
      petalPath.quadraticBezierTo(cp2x, cp2y, xStart, yStart);
      petalPath.close();

      canvas.drawPath(petalPath, paint);

      // Outline for non-active petals
      if (!isActive) {
        final outlinePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = inactiveColor.withOpacity(0.5);
        canvas.drawPath(petalPath, outlinePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
