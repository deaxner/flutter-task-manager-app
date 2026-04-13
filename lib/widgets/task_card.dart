import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_task_manager_app/models/task.dart';
import 'package:flutter_task_manager_app/models/time_entry.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.activeEntry,
    required this.onEdit,
    required this.onDelete,
    required this.onStartWork,
    required this.onStopWork,
    required this.onAddLog,
  });

  final Task task;
  final TimeEntry? activeEntry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStartWork;
  final VoidCallback onStopWork;
  final VoidCallback onAddLog;

  Color _priorityColor() {
    switch (task.priority) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF22C55E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color priorityColor = _priorityColor();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        task.project.name,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.blueGrey.shade600,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == 'edit') {
                      onEdit();
                    } else {
                      onDelete();
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                ),
              ],
            ),
            if (task.description != null &&
                task.description!.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                task.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.blueGrey.shade700,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Chip(
                  label: Text(task.status.replaceAll('_', ' ')),
                  avatar: const Icon(Icons.flag_outlined, size: 16),
                ),
                Chip(
                  backgroundColor: priorityColor.withValues(alpha: 0.12),
                  label: Text(task.priority),
                  avatar: Icon(
                    Icons.priority_high_rounded,
                    size: 16,
                    color: priorityColor,
                  ),
                ),
                if (task.dueDate != null)
                  Chip(
                    label: Text(_formatDate(task.dueDate!)),
                    avatar: const Icon(Icons.event_outlined, size: 16),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _TimelineRow(
              label: 'Started',
              value: task.startedAt != null
                  ? _formatDateTime(task.startedAt!)
                  : 'Not started',
            ),
            const SizedBox(height: 6),
            _TimelineRow(
              label: 'Completed',
              value: task.completedAt != null
                  ? _formatDateTime(task.completedAt!)
                  : 'Not completed',
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                _MetricPill(
                  label: 'Lead',
                  value: _formatHours(_leadHours(task)),
                ),
                const SizedBox(width: 8),
                _MetricPill(
                  label: 'Cycle',
                  value: _formatHours(_cycleHours(task)),
                ),
                const SizedBox(width: 8),
                _MetricPill(
                  label: 'Logged',
                  value: _formatHours(task.totalLoggedMinutes / 60),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: activeEntry == null ? onStartWork : onStopWork,
                    icon: Icon(
                      activeEntry == null
                          ? Icons.play_circle_outline_rounded
                          : Icons.stop_circle_outlined,
                    ),
                    label: Text(
                      activeEntry == null ? 'Start work' : 'Stop work',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onAddLog,
                    icon: const Icon(Icons.schedule_send_outlined),
                    label: const Text('Add log'),
                  ),
                ),
              ],
            ),
            if (activeEntry != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'Active since ${_formatDateTime(activeEntry!.startedAt)}',
                style: TextStyle(color: Colors.blueGrey.shade700),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _leadHours(Task task) {
    if (task.completedAt == null) {
      return 0;
    }

    return task.completedAt!.difference(task.createdAt).inMinutes / 60;
  }

  double _cycleHours(Task task) {
    if (task.startedAt == null || task.completedAt == null) {
      return 0;
    }

    return task.completedAt!.difference(task.startedAt!).inMinutes / 60;
  }

  String _formatDate(DateTime value) {
    return '${value.day}/${value.month}/${value.year}';
  }

  String _formatDateTime(DateTime value) {
    return '${value.day}/${value.month}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  String _formatHours(double hours) {
    if (hours <= 0) {
      return '0h';
    }

    if (hours >= 24) {
      final double days = hours / 24;
      final String fixed = days >= 10
          ? days.toStringAsFixed(0)
          : days.toStringAsFixed(1);
      return '$fixed d';
    }

    return '${math.max(1, hours.round())}h';
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.blueGrey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
