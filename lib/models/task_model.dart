import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime dueDate;
  final bool hasReminder;
  final bool isCompleted;
  final List<DateTime>? reminderTimes; // Adjust if you have multiple reminders

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    this.hasReminder = false,
    this.isCompleted = false,
    this.reminderTimes,
  });

  // Convert Task to Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'dueDate': Timestamp.fromDate(dueDate),
      'hasReminder': hasReminder,
      'isCompleted': isCompleted,
      'reminderTimes': reminderTimes?.map((e) => Timestamp.fromDate(e)).toList(),
    };
  }

  // Convert Map to Task
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      hasReminder: map['hasReminder'] ?? false,
      isCompleted: map['isCompleted'] ?? false,
      reminderTimes: (map['reminderTimes'] as List<dynamic>?)
          ?.map((e) => (e as Timestamp).toDate())
          .toList(),
    );
  }

  // Method to create a copy of the Task with some updated fields
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    bool? hasReminder,
    bool? isCompleted,
    List<DateTime>? reminderTimes,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      hasReminder: hasReminder ?? this.hasReminder,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderTimes: reminderTimes ?? this.reminderTimes,
    );
  }
}
