import 'package:flutter/material.dart';

class IslamicFramePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  IslamicFramePainter({required this.color, this.strokeWidth = 1.5});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.miter;

    final double w = size.width;
    final double h = size.height;

    final Path path = Path();

    // Outer Border with cut-off corners
    const double cornerCut = 12.0;

    // Top Left
    path.moveTo(0, cornerCut);
    path.lineTo(cornerCut, 0);
    path.lineTo(w - cornerCut, 0); // Top Right
    path.lineTo(w, cornerCut);
    path.lineTo(w, h - cornerCut); // Bottom Right
    path.lineTo(w - cornerCut, h);
    path.lineTo(cornerCut, h); // Bottom Left
    path.lineTo(0, h - cornerCut);
    path.close();

    // Inner Decor elements
    const double inset = 6.0;
    final Path innerPath = Path();
    innerPath.moveTo(inset, cornerCut + inset);
    innerPath.lineTo(cornerCut + inset, inset);
    innerPath.lineTo(w - cornerCut - inset, inset);
    innerPath.lineTo(w - inset, cornerCut + inset);
    innerPath.lineTo(w - inset, h - cornerCut - inset);
    innerPath.lineTo(w - cornerCut - inset, h - inset);
    innerPath.lineTo(cornerCut + inset, h - inset);
    innerPath.lineTo(inset, h - cornerCut - inset);
    innerPath.close();

    // Draw lines
    canvas.drawPath(path, paint);

    // Draw inner thinner lines
    final innerPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.5;
    canvas.drawPath(innerPath, innerPaint);

    // Draw corner ornaments (simple diamonds)
    final fillPaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    _drawDiamond(canvas, fillPaint, Offset(cornerCut / 2, cornerCut / 2), 3);
    _drawDiamond(
      canvas,
      fillPaint,
      Offset(w - cornerCut / 2, cornerCut / 2),
      3,
    );
    _drawDiamond(
      canvas,
      fillPaint,
      Offset(w - cornerCut / 2, h - cornerCut / 2),
      3,
    );
    _drawDiamond(
      canvas,
      fillPaint,
      Offset(cornerCut / 2, h - cornerCut / 2),
      3,
    );
  }

  void _drawDiamond(Canvas canvas, Paint paint, Offset center, double radius) {
    final Path diamond = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy)
      ..close();
    canvas.drawPath(diamond, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
