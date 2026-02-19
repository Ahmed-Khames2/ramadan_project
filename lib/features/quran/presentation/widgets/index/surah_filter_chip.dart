import 'package:flutter/material.dart';

import 'package:ramadan_project/core/theme/app_theme.dart';

class SurahFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SurahFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isSelected
          ? AppTheme.primaryEmerald
          : (isDark ? theme.colorScheme.surface : Colors.white),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryEmerald
                  : AppTheme.primaryEmerald.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark
                        ? theme.colorScheme.onSurface
                        : AppTheme.primaryEmerald),
            ),
          ),
        ),
      ),
    );
  }
}
