import 'package:flutter/material.dart';
import '../../../../core/widgets/main_scaffold.dart';
import 'package:ramadan_project/features/home/presentation/pages/home_page.dart';
import 'package:ramadan_project/features/quran/presentation/pages/mushaf_page_view.dart';
import 'package:ramadan_project/features/khatmah/presentation/pages/khatmah_dashboard_page.dart';
import 'package:ramadan_project/features/azkar/presentation/pages/azkar_categories_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeDashboardPage(),
    const MushafPageView(),
    const KhatmahDashboardPage(),
    const AzkarCategoriesPage(),
  ];

  final List<String> _titles = [
    'الرئيسية',
    'المصحف الشريف',
    'متابعة الختمة',
    'حصن المسلم',
  ];

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      title: _titles[_currentIndex],
      currentIndex: _currentIndex,
      onTabSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}
