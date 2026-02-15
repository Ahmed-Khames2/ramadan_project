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
      backgroundColor: AppTheme.warmBeige,
      drawer: drawer,
      appBar: AppBar(
        title: Text(title),
        leading: showBackButton
            ? BackButton(onPressed: () => Navigator.pop(context))
            : null,
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: onTabSelected != null
          ? BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTabSelected,
              selectedItemColor: AppTheme.primaryEmerald,
              unselectedItemColor: AppTheme.textGrey,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book),
                  label: 'المصحف',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.track_changes),
                  label: 'الختمة',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'الأذكار',
                ),
              ],
            )
          : null,
    );
  }
}
