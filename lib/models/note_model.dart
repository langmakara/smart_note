import 'package:flutter/material.dart';

class Note {
  final String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime? updatedAt;
  Color color;
  bool isPinned;
  String category;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.color = Colors.purple,
    this.isPinned = false,
    this.category = 'Personal',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'color': color.toARGB32(),
      'isPinned': isPinned,
      'category': category,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      color: Color(map['color']),
      isPinned: map['isPinned'] ?? false,
      category: map['category'] ?? 'Personal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'color': color.toARGB32(),
      'isPinned': isPinned,
      'category': category,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      color: Color(json['color']),
      isPinned: json['isPinned'] ?? false,
      category: json['category'] ?? 'Personal',
    );
  }

  Note copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    Color? color,
    bool? isPinned,
    String? category,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      category: category ?? this.category,
    );
  }
}
