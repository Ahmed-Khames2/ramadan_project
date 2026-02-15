import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedReciter = 'ar.alafasy';
  bool _continuousPlayback = true;
  bool _wakelock = true;

  final Map<String, String> _reciters = {
    'ar.alafasy': 'الشيخ مشاري العفاسي',
    'ar.husary': 'الشيخ محمود الحصري',
    'ar.mahermuaiqly': 'الشيخ ماهر المعيقلي',
    'ar.abdulbasitmurattal': 'الشيخ عبد الباسط (مرتل)',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedReciter = prefs.getString('selected_reciter') ?? 'ar.alafasy';
      _continuousPlayback = prefs.getBool('continuous_playback') ?? true;
      _wakelock = prefs.getBool('wakelock_enabled') ?? true;
    });
  }

  Future<void> _saveReciter(String reciter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_reciter', reciter);
    setState(() => _selectedReciter = reciter);
  }

  Future<void> _toggleContinuousPlayback(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('continuous_playback', value);
    setState(() => _continuousPlayback = value);
  }

  Future<void> _toggleWakelock(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wakelock_enabled', value);
    setState(() => _wakelock = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الإعدادات',
          style: TextStyle(
            fontFamily: 'UthmanTaha',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryEmerald,
        foregroundColor: Colors.white,
      ),
      body: DecorativeBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('القراء'),
            const SizedBox(height: 12),
            ..._reciters.entries.map((entry) {
              return _buildReciterTile(entry.key, entry.value);
            }),
            const SizedBox(height: 24),
            _buildSectionTitle('التشغيل'),
            const SizedBox(height: 12),
            _buildSwitchTile(
              'التشغيل المتواصل',
              'تشغيل تلقائي للآية التالية',
              _continuousPlayback,
              _toggleContinuousPlayback,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('الشاشة'),
            const SizedBox(height: 12),
            _buildSwitchTile(
              'منع قفل الشاشة',
              'إبقاء الشاشة مضاءة أثناء القراءة',
              _wakelock,
              _toggleWakelock,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryEmerald,
        ),
      ),
    );
  }

  Widget _buildReciterTile(String key, String name) {
    final isSelected = _selectedReciter == key;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: IslamicCard(
        padding: EdgeInsets.zero,
        child: RadioListTile<String>(
          value: key,
          groupValue: _selectedReciter,
          onChanged: (value) {
            if (value != null) _saveReciter(value);
          },
          title: Text(
            name,
            style: TextStyle(
              fontFamily: 'UthmanTaha',
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryEmerald : AppTheme.textDark,
            ),
          ),
          activeColor: AppTheme.primaryEmerald,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return IslamicCard(
      padding: EdgeInsets.zero,
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.textGrey),
        ),
        activeColor: AppTheme.primaryEmerald,
      ),
    );
  }
}
