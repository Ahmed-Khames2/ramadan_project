import 'package:flutter/material.dart';

class PageFooterWidget extends StatelessWidget {
  final int pageNumber;

  const PageFooterWidget({super.key, required this.pageNumber});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Text(
        '$pageNumber',
        style: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'UthmanTaha',
          fontSize: 14,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
