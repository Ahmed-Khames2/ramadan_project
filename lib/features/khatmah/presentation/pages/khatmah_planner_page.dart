import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/khatmah/presentation/bloc/khatam_bloc.dart';


class KhatmahPlannerPage extends StatefulWidget {
  const KhatmahPlannerPage({super.key});

  @override
  State<KhatmahPlannerPage> createState() => _KhatmahPlannerPageState();
}

class _KhatmahPlannerPageState extends State<KhatmahPlannerPage> {
  int _selectedDurationMonths = 1;
  int _customDays = 30;
  bool _useCustomDays = false;
  bool _restDaysEnabled = false;
  final List<int> _selectedRestDays = [];
  final TextEditingController _titleController = TextEditingController(
    text: 'ختمة جديدة',
  );
  DateTime _startDate = DateTime.now();

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmBeige,
      appBar: AppBar(title: const Text('إعداد خطة الختمة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing4),
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
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppTheme.primaryEmerald,
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return Card(
      child: TextField(
        controller: _titleController,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: 'مثلاً: ختمة رمضان',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          fillColor: Colors.transparent,
          hintStyle: GoogleFonts.cairo(
            color: AppTheme.textGrey.withOpacity(0.5),
          ),
        ),
        style: GoogleFonts.cairo(),
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
          labelStyle: GoogleFonts.cairo(
            color: isSelected ? Colors.white : AppTheme.textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: AppTheme.surfaceWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          showCheckmark: false,
        );
      },
    );
  }

  Widget _buildCustomDaysInput() {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacing3),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('عدد الأيام:', style: GoogleFonts.cairo()),
              const Spacer(),
              SizedBox(
                width: 60,
                child: TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    fillColor: Colors.transparent,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _customDays = int.tryParse(value) ?? 30;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text('يوم', style: GoogleFonts.cairo(color: AppTheme.textGrey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartDatePicker() {
    return Card(
      child: ListTile(
        title: Text(
          intl.DateFormat('yyyy/MM/dd', 'ar').format(_startDate),
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(
          Icons.calendar_today,
          color: AppTheme.primaryEmerald,
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
    return Card(
      child: SwitchListTile(
        title: Text('تخصيص أيام راحة', style: GoogleFonts.cairo()),
        subtitle: Text(
          'لن يتم احتساب هذه الأيام في وردك اليومي',
          style: GoogleFonts.cairo(fontSize: 12),
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
            selectedColor: AppTheme.accentGold.withOpacity(0.3),
            checkmarkColor: AppTheme.primaryEmerald,
            labelStyle: GoogleFonts.cairo(fontSize: 12),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إنشاء الخطة بنجاح')));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryEmerald,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'بدء الختمة',
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
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
