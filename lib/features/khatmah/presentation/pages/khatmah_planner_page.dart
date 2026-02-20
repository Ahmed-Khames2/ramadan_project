import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart' as intl;
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/khatmah/presentation/bloc/khatam_bloc.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:ramadan_project/features/khatmah/domain/entities/khatmah_entities.dart';

class KhatmahPlannerPage extends StatefulWidget {
  final KhatmahPlan? initialPlan;
  const KhatmahPlannerPage({super.key, this.initialPlan});

  @override
  State<KhatmahPlannerPage> createState() => _KhatmahPlannerPageState();
}

class _KhatmahPlannerPageState extends State<KhatmahPlannerPage> {
  int _selectedDurationMonths = 1;
  int _customDays = 30;
  bool _useCustomDays = false;
  bool _restDaysEnabled = false;
  final List<int> _selectedRestDays = [];
  late TextEditingController _titleController;
  late DateTime _startDate;

  final List<Map<String, dynamic>> _durations = [
    {'label': 'شهر واحد', 'months': 1, 'days': 30},
    {'label': '3 أشهر', 'months': 3, 'days': 90},
    {'label': '6 أشهر', 'months': 6, 'days': 180},
    {'label': 'مخصص', 'months': 0, 'days': 30},
  ];

  final List<String> _weekDays = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialPlan?.title ?? 'ختمة جديدة',
    );
    _startDate = widget.initialPlan?.startDate ?? DateTime.now();

    if (widget.initialPlan != null) {
      final days = widget.initialPlan!.targetDays;
      _customDays = days;
      _restDaysEnabled = widget.initialPlan!.restDaysEnabled;
      _selectedRestDays.addAll(widget.initialPlan!.restDays);

      final durationIndex = _durations.indexWhere(
        (d) => d['days'] == days && d['months'] != 0,
      );
      if (durationIndex != -1) {
        _selectedDurationMonths = _durations[durationIndex]['months'];
        _useCustomDays = false;
      } else {
        _useCustomDays = true;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing4,
                    vertical: AppTheme.spacing2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionTitle('عنوان الختمة'),
                      _buildTitleInput(),
                      const SizedBox(height: AppTheme.spacing4),
                      _buildSectionTitle('مدة الختمة'),
                      _buildDurationSelection(),
                      if (_useCustomDays) _buildCustomDaysInput(),
                      const SizedBox(height: AppTheme.spacing4),
                      _buildSectionTitle('تاريخ البداية'),
                      _buildStartDatePicker(),
                      const SizedBox(height: AppTheme.spacing4),
                      _buildSectionTitle('أيام الراحة'),
                      _buildRestDaysToggle(),
                      if (_restDaysEnabled) _buildRestDaysPicker(),
                      const SizedBox(height: AppTheme.spacing8),
                      _buildCreateButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          const IslamicBackButton(),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initialPlan == null ? 'إعداد الختمة' : 'تعديل الختمة',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryEmerald,
                  height: 1.2,
                ),
              ),
              Text(
                widget.initialPlan == null
                    ? 'خطط لأهدافك ووزع وردك بذكاء'
                    : 'تعديل تفاصيل خطتك الحالية',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textGrey,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppTheme.spacing2,
        right: AppTheme.spacing1,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppTheme.primaryEmerald,
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _titleController,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: 'مثلاً: ختمة رمضان',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          fillColor: Colors.transparent,
          hintStyle: TextStyle(color: AppTheme.textGrey.withValues(alpha: 0.4)),
        ),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildDurationSelection() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _durations.length,
      itemBuilder: (context, index) {
        final duration = _durations[index];
        final isSelected = _useCustomDays
            ? duration['months'] == 0
            : _selectedDurationMonths == duration['months'] &&
                  duration['months'] != 0;

        return ChoiceChip(
          label: Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(duration['label']),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (duration['months'] == 0) {
                _useCustomDays = true;
              } else {
                _useCustomDays = false;
                _selectedDurationMonths = duration['months'];
                _customDays = duration['days'];
              }
            });
          },
          selectedColor: AppTheme.primaryEmerald,
          labelStyle: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected
                  ? AppTheme.primaryEmerald
                  : AppTheme.primaryEmerald.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          elevation: isSelected ? 4 : 0,
          shadowColor: AppTheme.primaryEmerald.withValues(alpha: 0.3),
          showCheckmark: false,
        );
      },
    );
  }

  Widget _buildCustomDaysInput() {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacing3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              'عدد الأيام:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.primaryEmerald,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryEmerald),
                  ),
                  fillColor: Colors.transparent,
                ),
                onChanged: (value) {
                  setState(() {
                    _customDays = int.tryParse(value) ?? 30;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'يوم',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartDatePicker() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          intl.DateFormat('yyyy/MM/dd', 'ar').format(_startDate),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.calendar_today_rounded,
            color: AppTheme.primaryEmerald,
            size: 20,
          ),
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _startDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            locale: const Locale('ar'),
          );
          if (picked != null) {
            setState(() => _startDate = picked);
          }
        },
      ),
    );
  }

  Widget _buildRestDaysToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: SwitchListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تخصيص أيام راحة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          'لن يتم احتساب هذه الأيام في وردك اليومي',
          style: TextStyle(fontSize: 11, color: AppTheme.textGrey),
        ),
        value: _restDaysEnabled,
        onChanged: (value) => setState(() => _restDaysEnabled = value),
        activeColor: AppTheme.primaryEmerald,
      ),
    );
  }

  Widget _buildRestDaysPicker() {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacing3),
      child: Wrap(
        spacing: 8,
        children: List.generate(7, (index) {
          final weekday = index + 1;
          final isSelected = _selectedRestDays.contains(weekday);

          return FilterChip(
            label: Text(_weekDays[index]),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedRestDays.add(weekday);
                } else {
                  _selectedRestDays.remove(weekday);
                }
              });
            },
            selectedColor: AppTheme.accentGold.withValues(alpha: 0.2),
            checkmarkColor: AppTheme.primaryEmerald,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? AppTheme.darkEmerald
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.accentGold
                    : AppTheme.primaryEmerald.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton(
      onPressed: () {
        final totalDays = _useCustomDays
            ? _customDays
            : _DurationsToDays(_selectedDurationMonths);

        context.read<KhatamBloc>().add(
          CreateAdvancedKhatmahPlan(
            targetDays: totalDays,
            startDate: _startDate,
            restDaysEnabled: _restDaysEnabled,
            restDays: _selectedRestDays,
            title: _titleController.text,
          ),
        );

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.initialPlan == null
                  ? 'تم إنشاء الخطة بنجاح'
                  : 'تم تحديث الخطة بنجاح',
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryEmerald,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        elevation: 8,
        shadowColor: AppTheme.primaryEmerald.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        widget.initialPlan == null ? 'بدء الختمة' : 'حفظ التعديلات',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  int _DurationsToDays(int months) {
    if (months == 1) return 30;
    if (months == 3) return 90;
    if (months == 6) return 180;
    return 30;
  }
}
