import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  @override
  Future<List<CalendarEvent>> getEvents() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/calendar_events.json',
      );
      final data = await json.decode(response) as List;
      return data.map((e) => CalendarEvent.fromJson(e)).toList();
    } catch (e) {
      // In a real app, we might log this or return an empty list
      return [];
    }
  }
}
