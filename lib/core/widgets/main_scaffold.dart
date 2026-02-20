import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final Widget? drawer;
  final bool showBackButton;
  final int currentIndex;
  final Function(int)? onTabSelected;

  const MainScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.drawer,
    this.showBackButton = false,
    this.currentIndex = 0,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // No global AppBar as requested
      appBar: null,
      extendBody: true, // Content flows behind the floating NavBar
      drawer: drawer,
      body: body,
      bottomNavigationBar: onTabSelected != null
          ? _ModernFloatingNavBar(
              currentIndex: currentIndex,
              onTap: onTabSelected!,
            )
          : null,
    );
  }
}

class _ModernFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _ModernFloatingNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme.of(context).brightness == Brightness.dark
              ? [const Color(0xFF0A2B1D), const Color(0xFF051C13)]
              : [
                  AppTheme.primaryEmerald,
                  AppTheme.primaryEmerald.withOpacity(0.9),
                ],
        ),
        borderRadius: BorderRadius.circular(35),
        border: Theme.of(context).brightness == Brightness.dark
            ? Border.all(
                color: AppTheme.primaryEmerald.withOpacity(0.2),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color:
                (Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : AppTheme.primaryEmerald)
                    .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavBarItem(
            icon: Icons.home_rounded,
            label: 'الرئيسية',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavBarItem(
            icon: Icons.menu_book_rounded,
            label: 'المصحف',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavBarItem(
            icon: Icons.auto_graph_rounded,
            label: 'الختمة',
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavBarItem(
            icon: Icons.settings_rounded,
            label: 'الإعدادات',
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(35),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
