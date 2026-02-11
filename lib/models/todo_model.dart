import 'package:flutter/material.dart';

class Todo {
  final String id;
  String title;
  String description;
  List<TodoItem> items;
  DateTime createdAt;
  DateTime? updatedAt;
  Color color;
  bool isCompleted;
  String priority;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.items = const [],
    required this.createdAt,
    this.updatedAt,
    this.color = Colors.blue,
    this.isCompleted = false,
    this.priority = 'Medium',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'color': color.toARGB32(),
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      items: (map['items'] as List? ?? [])
          .map((item) => TodoItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      color: Color(map['color'] ?? Colors.blue.toARGB32()),
      isCompleted: (map['isCompleted'] ?? 0) == 1,
      priority: map['priority'] ?? 'Medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'color': color.toARGB32(),
      'isCompleted': isCompleted,
      'priority': priority,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((item) => TodoItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      color: Color(json['color'] ?? Colors.blue.toARGB32()),
      isCompleted: json['isCompleted'] ?? false,
      priority: json['priority'] ?? 'Medium',
    );
  }

  Todo copyWith({
    String? title,
    String? description,
    List<TodoItem>? items,
    DateTime? updatedAt,
    Color? color,
    bool? isCompleted,
    String? priority,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      items: items ?? this.items,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }

  int get completedItems => items.where((item) => item.isCompleted).length;
  int get totalItems => items.length;
  double get progress => items.isEmpty ? 0 : completedItems / totalItems;
}

class TodoItem {
  String id;
  String text;
  bool isCompleted;

  TodoItem({required this.id, required this.text, this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text, 'isCompleted': isCompleted ? 1 : 0};
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'],
      text: map['text'],
      isCompleted: (map['isCompleted'] ?? 0) == 1,
    );
  }

  TodoItem copyWith({String? text, bool? isCompleted}) {
    return TodoItem(
      id: id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
