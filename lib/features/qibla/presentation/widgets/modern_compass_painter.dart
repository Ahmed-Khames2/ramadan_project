import 'dart:math' show pi, cos, sin;
import 'package:flutter/material.dart';

class ModernCompassPainter extends CustomPainter {
  final double pulseValue;
  final bool isStatic;
  final Color textColor;
  final Color backgroundColor;

  ModernCompassPainter({
    required this.pulseValue,
    this.isStatic = true,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (isStatic) {
      _drawOrnamentLayer(canvas, center, radius);
    } else {
      _drawDirectionRing(canvas, center, radius);
    }
  }

  void _drawOrnamentLayer(Canvas canvas, Offset center, double radius) {
    // Background circle using theme color
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Inner subtle ring using text color with opacity
    final borderPaint = Paint()
      ..color = textColor.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius * 0.9, borderPaint);
  }

  void _drawDirectionRing(Canvas canvas, Offset center, double radius) {
    final directions = [
      {'text': 'ج', 'angle': 0.0},
      {'text': 'غ', 'angle': pi / 2},
      {'text': 'ش', 'angle': pi},
      {'text': 'ق', 'angle': 3 * pi / 2},
    ];

    for (var dir in directions) {
      final angle = dir['angle'] as double;
      final double textRadius = radius * 1.1; // Slightly outside the circle

      final textPainter = TextPainter(
        text: TextSpan(
          text: dir['text'] as String,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout();

      final xText = center.dx + textRadius * cos(angle);
      final yText = center.dy + textRadius * sin(angle);

      canvas.save();
      canvas.translate(xText, yText);
      canvas.rotate(angle + pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ModernCompassPainter oldDelegate) =>
      pulseValue != oldDelegate.pulseValue || isStatic != oldDelegate.isStatic;
}
