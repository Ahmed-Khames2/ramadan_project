import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class IslamicCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const IslamicCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppTheme.accentGold.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? 20),
          splashColor: AppTheme.accentGold.withOpacity(0.05),
          highlightColor: AppTheme.accentGold.withOpacity(0.02),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacing4),
            child: child,
          ),
        ),
      ),
    );
  }
}

class IslamicBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color baseColor;

  const IslamicBadge({
    super.key,
    required this.text,
    required this.icon,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing3,
        vertical: AppTheme.spacing2 / 2,
      ),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(AppTheme.spacing2),
        border: Border.all(color: baseColor.withOpacity(0.2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: baseColor),
          const SizedBox(width: AppTheme.spacing2),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: baseColor,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrnamentalDivider extends StatelessWidget {
  final double? width;
  final Color? color;

  const OrnamentalDivider({super.key, this.width, this.color});

  @override
  Widget build(BuildContext context) {
    final dividerColor = (color ?? AppTheme.accentGold).withOpacity(0.4);
    final iconColor = (color ?? AppTheme.accentGold).withOpacity(0.7);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 1,
          width: width ?? 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, dividerColor],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing3),
          child: Icon(Icons.spa_rounded, size: 16, color: iconColor),
        ),
        Container(
          height: 1,
          width: width ?? 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [dividerColor, Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}

class RevelationBadge extends StatelessWidget {
  final bool isMakki;

  const RevelationBadge({super.key, required this.isMakki});

  @override
  Widget build(BuildContext context) {
    final Color baseColor = isMakki
        ? AppTheme.primaryEmerald
        : const Color(0xFF1565C0);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: baseColor.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMakki ? Icons.mosque_outlined : Icons.location_city_outlined,
            size: 10,
            color: baseColor,
          ),
          const SizedBox(width: 4),
          Text(
            isMakki ? 'مكية' : 'مدنية',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: baseColor,
            ),
          ),
        ],
      ),
    );
  }
}

class DecorativeBackground extends StatelessWidget {
  final Widget child;
  final bool showTexture;

  const DecorativeBackground({
    super.key,
    required this.child,
    this.showTexture = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          if (showTexture)
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: Image.asset(
                  'assets/images/paper_texture.png',
                  repeat: ImageRepeat.repeat,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}
