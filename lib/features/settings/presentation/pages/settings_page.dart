import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadan_project/presentation/blocs/theme_mode_cubit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contact_us_page.dart';
import 'dedication_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _wakelock = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _wakelock = prefs.getBool('wakelock_enabled') ?? true;
    });
  }

  Future<void> _toggleWakelock(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wakelock_enabled', value);
    setState(() => _wakelock = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecorativeBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              // Header Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الإعدادات',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryEmerald,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    'تحكم في تفضيلاتك ومظهر التطبيق',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGrey.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const OrnamentalDivider(width: 40),
                ],
              ),
              const SizedBox(height: 32),

              // Theme Selection Section
              _buildSectionTitle('المظهر'),
              const SizedBox(height: 12),
              _buildThemeSelector(context),
              const SizedBox(height: 28),

              // Reading Preferences Section
              _buildSectionTitle('تفضيلات القراءة'),
              const SizedBox(height: 12),
              IslamicCard(
                padding: EdgeInsets.zero,
                child: _buildSwitchTile(
                  'منع قفل الشاشة',
                  'إبقاء الشاشة مضاءة أثناء القراءة',
                  Icons.vibration_rounded,
                  _wakelock,
                  _toggleWakelock,
                ),
              ),
              const SizedBox(height: 28),

              // App Actions Section
              _buildSectionTitle('عن التطبيق'),
              const SizedBox(height: 12),
              IslamicCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildActionTile(
                      'مشاركة التطبيق',
                      'شارك "زاد" مع العائلة والأصدقاء',
                      Icons.share_rounded,
                      () {
                        Share.share(
                          'حمل تطبيق "زاد": رفيقك للقرآن والأذكار ومواقيت الصلاة.\n\nرابط تحميل التطبيق:\nhttps://drive.google.com/drive/folders/1OoGk397Kb6sUy5S-qDw8A4EVGK6K0Lhc?usp=drive_link',
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildActionTile(
                      'مراجعة أحدث نسخة',
                      'تحقق من توفر تحديثات جديدة للتطبيق',
                      Icons.update_rounded,
                      () async {
                        final url = Uri.parse(
                          'https://drive.google.com/drive/folders/1OoGk397Kb6sUy5S-qDw8A4EVGK6K0Lhc?usp=drive_link',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildActionTile(
                      'تواصل معنا',
                      'أرسل لنا اقتراحاتك أو استفساراتك',
                      Icons.mail_rounded,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactUsPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildActionTile(
                      'إهداء (صدقة جارية)',
                      'عن روح والد أحمد خميس',
                      Icons.favorite_rounded,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DedicationPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              // Version Info
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'النسخة 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryEmerald,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'صنع بكل حب ليرافقك في عبادتك',
                    style: TextStyle(fontSize: 11, color: AppTheme.textGrey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return BlocBuilder<ThemeModeCubit, AppThemeMode>(
      builder: (context, currentMode) {
        return IslamicCard(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              _buildThemeOption(
                context,
                'فاتح',
                Icons.wb_sunny_rounded,
                AppThemeMode.light,
                currentMode == AppThemeMode.light,
              ),
              _buildThemeOption(
                context,
                'داكن',
                Icons.nightlight_round,
                AppThemeMode.dark,
                currentMode == AppThemeMode.dark,
              ),
              _buildThemeOption(
                context,
                'تلقائي',
                Icons.brightness_auto_rounded,
                AppThemeMode.system,
                currentMode == AppThemeMode.system,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String label,
    IconData icon,
    AppThemeMode mode,
    bool isSelected,
  ) {
    final color = isSelected ? AppTheme.primaryEmerald : AppTheme.textGrey;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<ThemeModeCubit>().setThemeMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryEmerald.withValues(alpha: isDark ? 0.2 : 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryEmerald.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryEmerald.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryEmerald, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.textGrey.withValues(alpha: 0.6),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: AppTheme.textGrey.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppTheme.primaryEmerald.withValues(alpha: 0.9),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryEmerald.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryEmerald, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.textGrey.withValues(alpha: 0.6),
        ),
      ),
      activeColor: AppTheme.primaryEmerald,
      activeTrackColor: AppTheme.primaryEmerald.withValues(alpha: 0.3),
    );
  }
}
