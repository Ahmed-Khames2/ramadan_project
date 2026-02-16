import 'package:flutter/material.dart';

class BasmalaWidget extends StatelessWidget {
  final double scale;

  const BasmalaWidget({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 28),
      child: Text(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'AThuluthRegular',
          fontSize: (38 * scale).clamp(28, 52),
          height: 1.8,
          color: const Color(0xFF111111),
          fontWeight: FontWeight.w500,
          shadows: [
            Shadow(
              blurRadius: 1,
              offset: const Offset(0, 1),
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
      ),
    );
  }
}
