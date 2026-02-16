import 'package:flutter/material.dart';

class QuranZoomPill extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const QuranZoomPill({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      elevation: 3,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1.4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 20),
              color: const Color(0xFF2B1C00),
              onPressed: onZoomOut,
              tooltip: 'تصغير',
            ),
            Container(width: 1, height: 22, color: const Color(0xFFD4AF37)),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              color: const Color(0xFF2B1C00),
              onPressed: onZoomIn,
              tooltip: 'تكبير',
            ),
          ],
        ),
      ),
    );
  }
}
