import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';

// Events
abstract class CalendarEvent_E extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCalendarEvents extends CalendarEvent_E {}

class SelectDate extends CalendarEvent_E {
  final DateTime selectedDay;
  final DateTime focusedDay;
  SelectDate(this.selectedDay, this.focusedDay);
  @override
  List<Object?> get props => [selectedDay, focusedDay];
}

class ChangeMonth extends CalendarEvent_E {
  final DateTime focusedDay;
  ChangeMonth(this.focusedDay);
  @override
  List<Object?> get props => [focusedDay];
}

// State
class CalendarState extends Equatable {
  final List<CalendarEvent> allEvents;
  final List<CalendarEvent> selectedEvents;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final bool isLoading;

  CalendarState({
    this.allEvents = const [],
    this.selectedEvents = const [],
    DateTime? selectedDay,
    DateTime? focusedDay,
    this.isLoading = false,
  }) : selectedDay = selectedDay ?? DateTime.now(),
       focusedDay = focusedDay ?? DateTime.now();

  CalendarState copyWith({
    List<CalendarEvent>? allEvents,
    List<CalendarEvent>? selectedEvents,
    DateTime? selectedDay,
    DateTime? focusedDay,
    bool? isLoading,
  }) {
    return CalendarState(
      allEvents: allEvents ?? this.allEvents,
      selectedEvents: selectedEvents ?? this.selectedEvents,
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    allEvents,
    selectedEvents,
    selectedDay,
    focusedDay,
    isLoading,
  ];
}

// Bloc
class CalendarBloc extends Bloc<CalendarEvent_E, CalendarState> {
  final CalendarRepository _repository;

  CalendarBloc({required CalendarRepository repository})
    : _repository = repository,
      super(CalendarState()) {
    on<LoadCalendarEvents>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final events = await _repository.getEvents();
      emit(
        state.copyWith(
          allEvents: events,
          isLoading: false,
          selectedEvents: _getEventsForDay(state.selectedDay, events),
        ),
      );
    });

    on<SelectDate>((event, emit) {
      emit(
        state.copyWith(
          selectedDay: event.selectedDay,
          focusedDay: event.focusedDay,
          selectedEvents: _getEventsForDay(event.selectedDay, state.allEvents),
        ),
      );
    });

    on<ChangeMonth>((event, emit) {
      emit(state.copyWith(focusedDay: event.focusedDay));
    });
  }

  List<CalendarEvent> _getEventsForDay(
    DateTime day,
    List<CalendarEvent> events,
  ) {
    final hDay = HijriCalendar.fromDate(day);

    return events.where((event) {
      // Hijri-based matching (Religious events)
      if (event.hijriMonth != null && event.hijriDay != null) {
        return event.hijriMonth == hDay.hMonth && event.hijriDay == hDay.hDay;
      }

      // Gregorian-based matching (National events)
      if (event.date != null) {
        return event.date!.year == day.year &&
            event.date!.month == day.month &&
            event.date!.day == day.day;
      }

      return false;
    }).toList();
  }
}
