import 'dart:math' show pi, cos, sin;
import 'package:flutter/material.dart';

import 'package:ramadan_project/core/theme/app_theme.dart';

class ModernCompassPainter extends CustomPainter {
  final double pulseValue;

  ModernCompassPainter({required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer decorative rings
    for (int i = 0; i < 3; i++) {
      final ringPaint = Paint()
        ..color = AppTheme.primaryEmerald.withOpacity(0.05 - i * 0.015)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawCircle(center, radius - i * 8, ringPaint);
    }

    // Main compass ring
    final ringPaint = Paint()
      ..color = AppTheme.primaryEmerald.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 25, ringPaint);

    // Cardinal directions with glassmorphic background
    final directions = [
      {'text': 'ش', 'angle': 0.0},
      {'text': 'ق', 'angle': pi / 2},
      {'text': 'ج', 'angle': pi},
      {'text': 'غ', 'angle': 3 * pi / 2},
    ];

    for (var dir in directions) {
      final angle = dir['angle'] as double;
      final isNorth = angle == 0.0;
      final x = center.dx + (radius - 50) * cos(angle - pi / 2);
      final y = center.dy + (radius - 50) * sin(angle - pi / 2);

      // Glassmorphic background
      final bgPaint = Paint()
        ..color = isNorth
            ? AppTheme.primaryEmerald.withOpacity(0.15)
            : Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 26, bgPaint);

      // Border
      final borderPaint = Paint()
        ..color = isNorth
            ? AppTheme.primaryEmerald.withOpacity(0.4)
            : AppTheme.primaryEmerald.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isNorth ? 2.5 : 1.5;

      canvas.drawCircle(Offset(x, y), 26, borderPaint);

      // Text
      final textPainter = TextPainter(
        text: TextSpan(
          text: dir['text'] as String,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isNorth ? AppTheme.primaryEmerald : AppTheme.textGrey,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Tick marks with varying styles
    for (int i = 0; i < 360; i += 6) {
      final angle = i * (pi / 180);
      final isMajor = i % 90 == 0;
      final isMinor = i % 30 == 0;

      if (isMajor) continue; // Skip cardinal directions

      final tickPaint = Paint()
        ..color = isMinor
            ? AppTheme.primaryEmerald.withOpacity(0.4)
            : AppTheme.primaryEmerald.withOpacity(0.15)
        ..strokeWidth = isMinor ? 2 : 1
        ..strokeCap = StrokeCap.round;

      final startRadius = radius - 20;
      final endRadius = isMinor ? radius - 35 : radius - 27;

      final start = Offset(
        center.dx + startRadius * cos(angle - pi / 2),
        center.dy + startRadius * sin(angle - pi / 2),
      );

      final end = Offset(
        center.dx + endRadius * cos(angle - pi / 2),
        center.dy + endRadius * sin(angle - pi / 2),
      );

      canvas.drawLine(start, end, tickPaint);
    }

    // Subtle Islamic geometric pattern in center
    final patternPaint = Paint()
      ..color = AppTheme.primaryEmerald.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 8; i++) {
      final angle = i * (pi / 4);
      final innerRadius = 80.0;
      final outerRadius = 100.0;

      final start = Offset(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );
      final end = Offset(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );

      canvas.drawLine(start, end, patternPaint);
    }
  }

  @override
  bool shouldRepaint(ModernCompassPainter oldDelegate) =>
      pulseValue != oldDelegate.pulseValue;
}
