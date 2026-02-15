import 'package:equatable/equatable.dart';

class CalendarEvent extends Equatable {
  final String title;
  final String description;
  final DateTime? date; // Gregorian (optional if Hijri based)
  final int? hijriMonth;
  final int? hijriDay;
  final String type; // 'islamic', 'national', 'other'
  final String? icon;

  const CalendarEvent({
    required this.title,
    required this.description,
    this.date,
    this.hijriMonth,
    this.hijriDay,
    required this.type,
    this.icon,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      title: json['title'],
      description: json['description'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      hijriMonth: json['hijriMonth'],
      hijriDay: json['hijriDay'],
      type: json['type'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date?.toIso8601String(),
      'hijriMonth': hijriMonth,
      'hijriDay': hijriDay,
      'type': type,
      'icon': icon,
    };
  }

  @override
  List<Object?> get props => [
    title,
    description,
    date,
    hijriMonth,
    hijriDay,
    type,
    icon,
  ];
}
