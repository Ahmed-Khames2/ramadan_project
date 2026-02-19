import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/arabic_digits_ext.dart';

class AyahSymbol extends StatelessWidget {
  final int ayahNumber;
  final double scale;

  const AyahSymbol({super.key, required this.ayahNumber, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          width: 32 * scale,
          height: 32 * scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/ayah_frame.svg',
                width: 32 * scale,
                height: 32 * scale,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFD4AF37),
                  BlendMode.srcIn,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  ayahNumber.toArabicDigits(),
                  style: const TextStyle(
                    fontFamily: 'UthmanTaha',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
