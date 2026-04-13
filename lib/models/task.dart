import 'package:flutter_task_manager_app/models/project.dart';

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.project,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.startedAt,
    required this.completedAt,
    required this.totalLoggedMinutes,
    required this.billableMinutes,
    required this.timeEntriesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String? description;
  final Project project;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int totalLoggedMinutes;
  final int billableMinutes;
  final int timeEntriesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      project: Project.fromJson(json['project'] as Map<String, dynamic>),
      status: json['status'] as String? ?? 'todo',
      priority: json['priority'] as String? ?? 'medium',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String)
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      totalLoggedMinutes: json['totalLoggedMinutes'] as int? ?? 0,
      billableMinutes: json['billableMinutes'] as int? ?? 0,
      timeEntriesCount: json['timeEntriesCount'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'projectId': project.id,
      'status': status,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    Project? project,
    String? status,
    String? priority,
    DateTime? dueDate,
    DateTime? startedAt,
    DateTime? completedAt,
    int? totalLoggedMinutes,
    int? billableMinutes,
    int? timeEntriesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      project: project ?? this.project,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      totalLoggedMinutes: totalLoggedMinutes ?? this.totalLoggedMinutes,
      billableMinutes: billableMinutes ?? this.billableMinutes,
      timeEntriesCount: timeEntriesCount ?? this.timeEntriesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
