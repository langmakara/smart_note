import 'package:flutter/material.dart';

class Event {
  final String id;
  String title;
  String description;
  DateTime startTime;
  DateTime endTime;
  Color color;
  bool isAllDay;
  bool isDone;
  String? location;
  int? reminderMinutes;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.color = Colors.blue,
    this.isAllDay = false,
    this.isDone = false,
    this.location,
    this.reminderMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'color': color.toARGB32(),
      'isAllDay': isAllDay,
      'isDone': isDone ? 1 : 0,
      'location': location,
      'reminderMinutes': reminderMinutes,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      color: Color(map['color'] ?? Colors.blue.toARGB32()),
      isAllDay: map['isAllDay'] ?? false,
      isDone: (map['isDone'] ?? 0) == 1,
      location: map['location'],
      reminderMinutes: map['reminderMinutes'],
    );
  }

  Event copyWith({
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    Color? color,
    bool? isAllDay,
    bool? isDone,
    String? location,
    int? reminderMinutes,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      isAllDay: isAllDay ?? this.isAllDay,
      isDone: isDone ?? this.isDone,
      location: location ?? this.location,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    );
  }

  bool isOnDate(DateTime date) {
    return startTime.year == date.year &&
        startTime.month == date.month &&
        startTime.day == date.day;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'color': color.toARGB32(),
      'isAllDay': isAllDay,
      'isDone': isDone,
      'location': location,
      'reminderMinutes': reminderMinutes,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      color: Color(json['color'] ?? Colors.blue.toARGB32()),
      isAllDay: json['isAllDay'] ?? false,
      isDone: json['isDone'] ?? false,
      location: json['location'],
      reminderMinutes: json['reminderMinutes'],
    );
  }
}
