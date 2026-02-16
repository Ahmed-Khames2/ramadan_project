import 'package:flutter/material.dart';

class BasmalaWidget extends StatelessWidget {
  final double scale;

  const BasmalaWidget({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 8),
      child: Text(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontFamily: 'UthmanTaha',
          fontSize: (26 * scale).clamp(20, 36),
          color: theme.colorScheme.onSurface.withOpacity(0.9),
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
