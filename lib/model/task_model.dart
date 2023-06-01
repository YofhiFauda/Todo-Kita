// lib/model/task_model.dart

import 'package:flutter/material.dart';

class Task {
  final int id;
  String title;
  String description;
  TimeOfDay time;
  Color color;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.color,
    required this.isCompleted,
  });

  Task copyWith({
    String? title,
    String? description,
    TimeOfDay? time,
    Color? color,
    bool? isCompleted,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time.toString(),
      'color': color.value,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}
