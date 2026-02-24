import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:ramadan_project/features/prayer_times/presentation/bloc/prayer_bloc.dart';
import 'package:ramadan_project/core/utils/string_extensions.dart';

import '../../domain/entities/prayer_time.dart';
import '../../domain/entities/governorate.dart';

class PrayerHeader extends StatelessWidget {
  const PrayerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Basic Hijri date approximation or just static for now
    final hijriDate = 'رمضان ١٤٤٧ هـ';
    final gregorianDate = intl.DateFormat(
      'EEEE, d MMMM',
      'ar',
    ).format(DateTime.now());

    return Column(
      children: [
        const SizedBox(height: AppTheme.spacing2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing2),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mosque_rounded,
                color: AppTheme.accentGold,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacing3),
            Text(
              'نور الإيمان',
              style: TextStyle(
                fontFamily: 'UthmanTaha',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.secondary
                    : AppTheme.primaryEmerald,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing2),
        Text(
          hijriDate,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        Text(
          gregorianDate.toArabicNumbers(),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: AppTheme.spacing3),
        const CompactGovernorateSelector(),
        const SizedBox(height: AppTheme.spacing4),
        const OrnamentalDivider(width: 100),
      ],
    );
  }
}

class CompactGovernorateSelector extends StatefulWidget {
  const CompactGovernorateSelector({super.key});

  @override
  State<CompactGovernorateSelector> createState() =>
      _CompactGovernorateSelectorState();
}

class _CompactGovernorateSelectorState
    extends State<CompactGovernorateSelector> {
  Governorate? _selectedGovernorate;
  List<Governorate> _governorates = [];

  @override
  void initState() {
    super.initState();
    _loadGovernorateSelection();
  }

  Future<void> _loadGovernorateSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGovernorateName = prefs.getString('selected_governorate_name');

    // Get governorates from bloc
    if (mounted) {
      final state = context.read<PrayerBloc>().state;
      if (state is PrayerLoaded) {
        setState(() {
          _governorates = state.governorates;
          if (savedGovernorateName != null) {
            _selectedGovernorate = _governorates.firstWhere(
              (gov) => gov.nameArabic == savedGovernorateName,
              orElse: () => state.selectedGovernorate,
            );
          } else {
            _selectedGovernorate = state.selectedGovernorate;
          }
        });
      }
    }
  }

  Future<void> _saveGovernorateSelection(Governorate governorate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_governorate_name', governorate.nameArabic);
  }

  @override
  Widget build(BuildContext context) {
    if (_governorates.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Governorate>(
          value: _selectedGovernorate,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Theme.of(context).colorScheme.secondary,
            size: 18,
          ),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          items: _governorates.map((gov) {
            return DropdownMenuItem(value: gov, child: Text(gov.nameArabic));
          }).toList(),
          onChanged: (gov) {
            if (gov != null) {
              setState(() => _selectedGovernorate = gov);
              _saveGovernorateSelection(gov);
              context.read<PrayerBloc>().add(SelectGovernorate(gov));
            }
          },
        ),
      ),
    );
  }
}

class PrayerSettingsSheet extends StatelessWidget {
  const PrayerSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing6),
      child: BlocBuilder<PrayerBloc, PrayerState>(
        builder: (context, state) {
          if (state is! PrayerLoaded) return const SizedBox.shrink();

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إعدادات التنبيهات',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing4),
              SwitchListTile(
                title: Text(
                  'تفعيل تنبيهات الصلاة',
                  style: TextStyle(fontSize: 16),
                ),
                subtitle: Text(
                  'سوف تتلقى تنبيها قبل كل صلاة',
                  style: TextStyle(fontSize: 12),
                ),
                value: state.notificationsEnabled,
                activeColor: AppTheme.primaryEmerald,
                onChanged: (val) {
                  context.read<PrayerBloc>().add(ToggleNotifications(val));
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وقت التنبيه قبل الصلاة',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      value: state.leadTimeMinutes,
                      isExpanded: true,
                      items: [0, 5, 10, 15, 30].map((mins) {
                        return DropdownMenuItem(
                          value: mins,
                          child: Text(
                            mins == 0
                                ? 'في وقت الصلاة'
                                : '${mins.toArabic()} دقائق قبل الصلاة',
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          context.read<PrayerBloc>().add(UpdateLeadTime(val));
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing6),
            ],
          );
        },
      ),
    );
  }
}

class GovernorateSelector extends StatelessWidget {
  final List<Governorate> governorates;
  final Governorate selected;
  final ValueChanged<Governorate?> onSelected;

  const GovernorateSelector({
    super.key,
    required this.governorates,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing6),
      child: IslamicCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing4,
          vertical: 4,
        ),
        borderRadius: 12,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Governorate>(
            value: selected,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.accentGold,
            ),
            items: governorates.map((gov) {
              return DropdownMenuItem(
                value: gov,
                child: Text(
                  gov.nameArabic,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
            onChanged: onSelected,
          ),
        ),
      ),
    );
  }
}

class CurrentPrayerCard extends StatelessWidget {
  final List<PrayerTime> prayers;

  const CurrentPrayerCard({super.key, required this.prayers});

  @override
  Widget build(BuildContext context) {
    PrayerTime? current;
    PrayerTime? next;

    final now = DateTime.now();
    for (int i = 0; i < prayers.length; i++) {
      if (prayers[i].isCurrent) {
        current = prayers[i];
        next = prayers[(i + 1) % prayers.length];
        break;
      }
    }

    // Fallback if adhan is between Isha and Fajr next day
    if (current == null) {
      current = prayers.last; // Default to Isha
      next = prayers.first;
    }

    final timeLeft = next!.time.difference(now);
    final hours = timeLeft.inHours;
    final minutes = timeLeft.inMinutes % 60;

    return Container(
      margin: const EdgeInsets.all(AppTheme.spacing6),
      child: IslamicCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryEmerald,
                AppTheme.primaryEmerald.withOpacity(0.85),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(
                  Icons.auto_awesome,
                  size: 150,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing6),
                child: Column(
                  children: [
                    Text(
                      'الصلاة القادمة: ${next.nameArabic}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Text(
                      intl.DateFormat.jm(
                        'ar',
                      ).format(next.time).toArabicNumbers(),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'متبقي ${hours.toArabic()} ساعة و ${minutes.toArabic()} دقيقة',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrayerTimeRow extends StatelessWidget {
  final PrayerTime prayer;
  final bool isCurrent;

  const PrayerTimeRow({
    super.key,
    required this.prayer,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing3,
      ),
      decoration: BoxDecoration(
        color: isCurrent
            ? (Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.primaryEmerald.withOpacity(0.2)
                  : AppTheme.primaryEmerald.withOpacity(0.08))
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? AppTheme.primaryEmerald
              : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : AppTheme.primaryEmerald.withOpacity(0.1)),
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryEmerald.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForPrayer(prayer.nameEnglish),
              size: 20,
              color: AppTheme.primaryEmerald,
            ),
          ),
          const SizedBox(width: AppTheme.spacing4),
          Text(
            prayer.nameArabic,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Text(
            intl.DateFormat.jm('ar').format(prayer.time).toArabicNumbers(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isCurrent
                  ? AppTheme.primaryEmerald
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForPrayer(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight_rounded;
      case 'dhuhr':
        return Icons.wb_sunny_rounded;
      case 'asr':
        return Icons.wb_cloudy_rounded;
      case 'maghrib':
        return Icons.nights_stay_rounded;
      case 'isha':
        return Icons.bedtime_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }
}
