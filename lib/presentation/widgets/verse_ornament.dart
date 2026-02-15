import 'dart:math' as math;
import 'package:flutter/material.dart';

class VerseOrnament extends StatelessWidget {
  final int ayahNumber;
  final double size;
  final Color color;

  const VerseOrnament({
    super.key,
    required this.ayahNumber,
    this.size = 28.0,
    this.color = const Color(0xFFC5A059), // Gold accent
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Islamic Ornament
          CustomPaint(
            size: Size(size, size),
            painter: _OrnamentPainter(color: color),
          ),
          Text(
            ayahNumber.toString(),
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.9),
              fontFamily: 'UthmanTaha',
            ),
          ),
        ],
      ),
    );
  }
}

class _OrnamentPainter extends CustomPainter {
  final Color color;

  _OrnamentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer circle
    canvas.drawCircle(center, radius, paint);

    // Inner circle
    canvas.drawCircle(center, radius * 0.82, paint);

    // 8-pointed star pattern
    final path = Path();
    const int points = 8;
    for (int i = 0; i < points * 2; i++) {
      final r = (i % 2 == 0) ? radius : radius * 0.9;
      final angle = i * math.pi / points;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
