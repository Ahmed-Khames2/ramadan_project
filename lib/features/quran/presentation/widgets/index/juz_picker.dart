import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';

class JuzPicker extends StatelessWidget {
  final int? selectedJuz;
  final ValueChanged<int?> onChanged;

  const JuzPicker({
    super.key,
    required this.selectedJuz,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int?>(
      value: selectedJuz,
      hint: Text('اختر الجزء', style: GoogleFonts.cairo(fontSize: 14)),
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryEmerald),
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text('كل الأجزاء', style: GoogleFonts.cairo()),
        ),
        ...List.generate(30, (i) => i + 1).map((juz) {
          return DropdownMenuItem<int?>(
            value: juz,
            child: Text('الجزء $juz', style: GoogleFonts.cairo()),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }
}
