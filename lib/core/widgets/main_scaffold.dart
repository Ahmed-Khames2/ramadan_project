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
    // Hide AppBar for home page (currentIndex = 0)
    final showAppBar = currentIndex != 0;

    return Scaffold(
      backgroundColor: AppTheme.warmBeige,
      drawer: drawer,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: AppTheme.primaryEmerald,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              title: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'UthmanTaha',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              leading: showBackButton
                  ? BackButton(onPressed: () => Navigator.pop(context))
                  : null,
              actions: actions,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: AppTheme.accentGold),
              ),
            )
          : null,
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
