import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:ramadan_project/features/prayer_times/presentation/bloc/calendar_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../domain/entities/calendar_event.dart';
import '../../data/repositories/calendar_repository_impl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late CalendarBloc _calendarBloc;

  @override
  void initState() {
    super.initState();
    _calendarBloc = CalendarBloc(repository: CalendarRepositoryImpl())
      ..add(LoadCalendarEvents());
  }

  @override
  void dispose() {
    _calendarBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _calendarBloc,
      child: Scaffold(
        body: DecorativeBackground(
          child: SafeArea(
            child: BlocBuilder<CalendarBloc, CalendarState>(
              builder: (context, state) {
                return Column(
                  children: [
                    _buildHeader(context, state),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildCalendarView(state),
                            const SizedBox(height: 24),
                            const OrnamentalDivider(),
                            _buildEventsList(state),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _getArabicHijriMonth(int month) {
    const months = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    return months[month - 1];
  }

  Widget _buildHeader(BuildContext context, CalendarState state) {
    final hijriDate = HijriCalendar.fromDate(state.focusedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.primaryEmerald,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            children: [
              Text(
                'التقويم الإسلامي',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryEmerald,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_getArabicHijriMonth(hijriDate.hMonth)} ${hijriDate.hYear}هـ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '|',
                    style: TextStyle(
                      color: AppTheme.accentGold.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${state.focusedDay.year}م',
                    style: TextStyle(fontSize: 14, color: AppTheme.accentGold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCalendarView(CalendarState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : AppTheme.primaryEmerald.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppTheme.accentGold.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          locale: 'ar',
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: state.focusedDay,
          selectedDayPredicate: (day) => isSameDay(state.selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            _calendarBloc.add(SelectDate(selectedDay, focusedDay));
          },
          onPageChanged: (focusedDay) {
            _calendarBloc.add(ChangeMonth(focusedDay));
          },
          calendarFormat: CalendarFormat.month,
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) =>
                _buildDayCell(day, isSelected: false, isToday: false),
            todayBuilder: (context, day, focusedDay) =>
                _buildDayCell(day, isSelected: false, isToday: true),
            selectedBuilder: (context, day, focusedDay) =>
                _buildDayCell(day, isSelected: true, isToday: false),
            markerBuilder: (context, day, events) {
              final hDay = HijriCalendar.fromDate(day);
              final dayEvents = state.allEvents.where((e) {
                if (e.hijriMonth != null && e.hijriDay != null) {
                  return e.hijriMonth == hDay.hMonth && e.hijriDay == hDay.hDay;
                }
                if (e.date != null) return isSameDay(e.date!, day);
                return false;
              }).toList();

              if (dayEvents.isEmpty) return const SizedBox.shrink();

              return Positioned(
                bottom: 8,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentGold,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold,
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryEmerald,
            ),
            leftChevronIcon: const Icon(
              Icons.chevron_left,
              color: AppTheme.primaryEmerald,
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
              color: AppTheme.primaryEmerald,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: AppTheme.textGrey,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            weekendStyle: TextStyle(
              color: AppTheme.accentGold,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            isTodayHighlighted: true,
            todayDecoration: BoxDecoration(
              color: AppTheme.softGold,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: AppTheme.primaryEmerald,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day, {
    required bool isSelected,
    required bool isToday,
  }) {
    final hijriDate = HijriCalendar.fromDate(day);

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryEmerald
            : isToday
            ? AppTheme.softGold.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isToday && !isSelected
            ? Border.all(color: AppTheme.accentGold.withOpacity(0.5))
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              height: 1.1,
            ),
          ),
          Text(
            '${hijriDate.hDay}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.bold,
              color: isSelected
                  ? Colors.white.withOpacity(0.9)
                  : AppTheme.accentGold,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(CalendarState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              const Icon(
                Icons.event_note_rounded,
                color: AppTheme.accentGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'مناسبات هجرية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryEmerald,
                ),
              ),
            ],
          ),
        ),
        if (state.selectedEvents.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'لا توجد مناسبات رسمية لهذا اليوم',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
              ),
            ),
          )
        else
          ...state.selectedEvents.map((event) => _buildEventCard(event)),
      ],
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryEmerald.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEventDetails(event),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryEmerald.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    event.icon ?? '🌙',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        event.description,
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppTheme.accentGold,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEventDetails(CalendarEvent event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildEventDetailSheet(event),
    );
  }

  Widget _buildEventDetailSheet(CalendarEvent event) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textGrey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryEmerald.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accentGold.withOpacity(0.2)),
            ),
            child: Text(
              event.icon ?? '🌙',
              style: const TextStyle(fontSize: 48),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            event.title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryEmerald,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
            ),
            child: Text(
              'مناسبة دينية إسلامية',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentGold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            event.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textDark,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryEmerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'تم',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
