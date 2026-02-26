import 'package:flutter/material.dart';
import '../../../../core/widgets/main_scaffold.dart';
import 'package:ramadan_project/features/home/presentation/pages/home_page.dart';
import 'package:ramadan_project/features/khatmah/presentation/pages/khatmah_dashboard_page.dart';
// import 'package:ramadan_project/features/prayer_times/presentation/pages/prayer_calendar_page.dart';
import 'package:ramadan_project/features/settings/presentation/pages/settings_page.dart';
import 'package:ramadan_project/features/quran/presentation/pages/enhanced_surah_index_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  late final List<Widget> _pages = [
    const HomeDashboardPage(),
    const EnhancedSurahIndexPage(),
    const KhatmahDashboardPage(),
    const SettingsPage(),
  ];

  final List<String> _titles = [
    'الرئيسية',
    'فهرس القرآن',
    'متابعة الختمة',
    'الإعدادات',
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          return;
        }
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: MainScaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        title: _titles[_currentIndex],
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
