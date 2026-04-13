import 'package:flutter/material.dart';
import 'package:flutter_task_manager_app/models/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _priorityColor(BuildContext context) {
    switch (task.priority) {
      case 'high':
        return Colors.red.shade400;
      case 'medium':
        return Colors.orange.shade400;
      default:
        return Colors.green.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    task.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
            const SizedBox(height: 10),
            if (task.description != null && task.description!.trim().isNotEmpty)
              Text(
                task.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.blueGrey.shade700,
                ),
              ),
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
                  backgroundColor: _priorityColor(context).withValues(alpha: 0.12),
                  label: Text(task.priority),
                  avatar: Icon(
                    Icons.priority_high_rounded,
                    size: 16,
                    color: _priorityColor(context),
                  ),
                ),
                if (task.dueDate != null)
                  Chip(
                    label: Text(
                      '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                    ),
                    avatar: const Icon(Icons.event_outlined, size: 16),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
