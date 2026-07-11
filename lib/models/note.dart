import 'dart:convert';
import 'package:flutter/material.dart';

class TodoItem {
  String id;
  String title;
  bool isDone;

  TodoItem({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isDone: map['isDone'] ?? false,
    );
  }
}

class DrawingPoint {
  double x;
  double y;

  DrawingPoint(this.x, this.y);

  Map<String, double> toMap() {
    return {'x': x, 'y': y};
  }

  factory DrawingPoint.fromMap(Map<String, dynamic> map) {
    return DrawingPoint(
      (map['x'] as num).toDouble(),
      (map['y'] as num).toDouble(),
    );
  }

  Offset toOffset() => Offset(x, y);
}

class DrawingStroke {
  List<DrawingPoint> points;
  int colorValue;
  double strokeWidth;

  DrawingStroke({
    required this.points,
    required this.colorValue,
    this.strokeWidth = 4.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'points': points.map((p) => p.toMap()).toList(),
      'colorValue': colorValue,
      'strokeWidth': strokeWidth,
    };
  }

  factory DrawingStroke.fromMap(Map<String, dynamic> map) {
    return DrawingStroke(
      points: (map['points'] as List)
          .map((p) => DrawingPoint.fromMap(p))
          .toList(),
      colorValue: map['colorValue'] ?? Colors.white.value,
      strokeWidth: (map['strokeWidth'] as num?)?.toDouble() ?? 4.0,
    );
  }
}


class Note {
  String id;
  String title;
  String content;
  String category;
  DateTime dateCreated;
  DateTime dateModified;
  bool isPinned;
  bool isArchived;
  bool isTrashed;
  bool isLocked; // New field
  DateTime? reminderDate; // New field
  List<TodoItem> todos;
  List<DrawingStroke> sketchStrokes;
  String? aiSummary; // New field
  List<String> tags; // New field
  String? coverValue; // New field
  bool isEncrypted; // New field

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'Pribadi',
    required this.dateCreated,
    required this.dateModified,
    this.isPinned = false,
    this.isArchived = false,
    this.isTrashed = false,
    this.isLocked = false,
    this.reminderDate,
    this.todos = const [],
    this.sketchStrokes = const [],
    this.aiSummary,
    this.tags = const [],
    this.coverValue,
    this.isEncrypted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified.toIso8601String(),
      'isPinned': isPinned,
      'isArchived': isArchived,
      'isTrashed': isTrashed,
      'isLocked': isLocked,
      'reminderDate': reminderDate?.toIso8601String(),
      'todos': todos.map((x) => x.toMap()).toList(),
      'sketchStrokes': sketchStrokes.map((x) => x.toMap()).toList(),
      'aiSummary': aiSummary,
      'tags': tags,
      'coverValue': coverValue,
      'isEncrypted': isEncrypted,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? 'Pribadi',
      dateCreated: DateTime.parse(map['dateCreated'] ?? DateTime.now().toIso8601String()),
      dateModified: DateTime.parse(map['dateModified'] ?? DateTime.now().toIso8601String()),
      isPinned: map['isPinned'] ?? false,
      isArchived: map['isArchived'] ?? false,
      isTrashed: map['isTrashed'] ?? false,
      isLocked: map['isLocked'] ?? false,
      reminderDate: map['reminderDate'] != null ? DateTime.parse(map['reminderDate']) : null,
      todos: map['todos'] != null
          ? List<TodoItem>.from((map['todos'] as List).map((x) => TodoItem.fromMap(x)))
          : [],
      sketchStrokes: map['sketchStrokes'] != null
          ? List<DrawingStroke>.from((map['sketchStrokes'] as List).map((x) => DrawingStroke.fromMap(x)))
          : [],
      aiSummary: map['aiSummary'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : const [],
      coverValue: map['coverValue'],
      isEncrypted: map['isEncrypted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) => Note.fromMap(json.decode(source));

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    DateTime? dateCreated,
    DateTime? dateModified,
    bool? isPinned,
    bool? isArchived,
    bool? isTrashed,
    bool? isLocked,
    DateTime? reminderDate,
    bool clearReminder = false,
    List<TodoItem>? todos,
    List<DrawingStroke>? sketchStrokes,
    String? aiSummary,
    List<String>? tags,
    String? coverValue,
    bool clearCover = false,
    bool? isEncrypted,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isTrashed: isTrashed ?? this.isTrashed,
      isLocked: isLocked ?? this.isLocked,
      reminderDate: clearReminder ? null : (reminderDate ?? this.reminderDate),
      todos: todos ?? this.todos,
      sketchStrokes: sketchStrokes ?? this.sketchStrokes,
      aiSummary: aiSummary ?? this.aiSummary,
      tags: tags ?? this.tags,
      coverValue: clearCover ? null : (coverValue ?? this.coverValue),
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }
}
