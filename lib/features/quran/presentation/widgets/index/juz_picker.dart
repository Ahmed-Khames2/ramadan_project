import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : theme.colorScheme.onSurface;

    return DropdownButton<int?>(
      value: selectedJuz,
      dropdownColor: isDark ? theme.cardColor : Colors.white,
      hint: Text(
        'اختر الجزء',
        style: TextStyle(fontSize: 14, color: textColor),
      ),
      style: TextStyle(fontSize: 14, color: textColor),
      underline: const SizedBox(),
      icon: Icon(
        Icons.arrow_drop_down,
        color: isDark ? theme.colorScheme.secondary : AppTheme.primaryEmerald,
      ),
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text('كل الأجزاء', style: TextStyle(color: textColor)),
        ),
        ...List.generate(30, (i) => i + 1).map((juz) {
          return DropdownMenuItem<int?>(
            value: juz,
            child: Text('الجزء $juz', style: TextStyle(color: textColor)),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }
}
