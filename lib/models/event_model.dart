import 'package:flutter/material.dart';

class Event {
  final String id;
  String title;
  String description;
  DateTime startTime;
  DateTime endTime;
  Color color;
  bool isAllDay;
  String? location;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.color = Colors.blue,
    this.isAllDay = false,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'color': color.value,
      'isAllDay': isAllDay,
      'location': location,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      color: Color(map['color']),
      isAllDay: map['isAllDay'] ?? false,
      location: map['location'],
    );
  }

  Event copyWith({
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    Color? color,
    bool? isAllDay,
    String? location,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      isAllDay: isAllDay ?? this.isAllDay,
      location: location ?? this.location,
    );
  }

  bool isOnDate(DateTime date) {
    return startTime.year == date.year &&
        startTime.month == date.month &&
        startTime.day == date.day;
  }
}
