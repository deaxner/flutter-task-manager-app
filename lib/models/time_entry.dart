class TimeEntry {
  const TimeEntry({
    required this.id,
    required this.taskId,
    required this.projectId,
    required this.projectName,
    required this.startedAt,
    required this.endedAt,
    required this.minutes,
    required this.billable,
    required this.notes,
  });

  final int id;
  final int taskId;
  final int projectId;
  final String projectName;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int minutes;
  final bool billable;
  final String? notes;

  bool get isOpen => endedAt == null;

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'] as int,
      taskId: json['taskId'] as int,
      projectId: json['projectId'] as int,
      projectName: json['projectName'] as String? ?? '',
      startedAt:
          DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.now(),
      endedAt: json['endedAt'] != null
          ? DateTime.tryParse(json['endedAt'] as String)
          : null,
      minutes: json['minutes'] as int? ?? 0,
      billable: json['billable'] as bool? ?? true,
      notes: json['notes'] as String?,
    );
  }
}
