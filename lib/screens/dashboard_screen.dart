import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_task_manager_app/models/project.dart';
import 'package:flutter_task_manager_app/models/task.dart';
import 'package:flutter_task_manager_app/models/time_entry.dart';
import 'package:flutter_task_manager_app/screens/task_form_screen.dart';
import 'package:flutter_task_manager_app/utils/constants.dart';
import 'package:flutter_task_manager_app/widgets/task_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.projects,
    required this.tasks,
    required this.timeEntries,
    required this.isLoading,
    required this.errorMessage,
    required this.searchController,
    required this.selectedProjectId,
    required this.selectedStatus,
    required this.selectedPriority,
    required this.onSearchChanged,
    required this.onProjectChanged,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onRefresh,
    required this.onLogout,
    required this.onCreateTask,
    required this.onUpdateTask,
    required this.onDeleteTask,
    required this.onStartWork,
    required this.onStopWork,
    required this.onCreateManualTimeEntry,
  });

  final List<Project> projects;
  final List<Task> tasks;
  final List<TimeEntry> timeEntries;
  final bool isLoading;
  final String? errorMessage;
  final TextEditingController searchController;
  final String selectedProjectId;
  final String selectedStatus;
  final String selectedPriority;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onProjectChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPriorityChanged;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;
  final Future<void> Function(Task draft) onCreateTask;
  final Future<void> Function(Task draft) onUpdateTask;
  final Future<void> Function(Task task) onDeleteTask;
  final Future<void> Function(Task task) onStartWork;
  final Future<void> Function(Task task) onStopWork;
  final Future<void> Function(
    Task task,
    DateTime startedAt,
    DateTime endedAt,
    bool billable,
    String? notes,
  )
  onCreateManualTimeEntry;

  Future<void> _openTaskForm(BuildContext context, {Task? task}) async {
    if (projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No projects available yet. Seed or create projects first.',
          ),
        ),
      );
      return;
    }

    final Task? draft = await Navigator.of(context).push<Task>(
      MaterialPageRoute<Task>(
        builder: (_) => TaskFormScreen(initialTask: task, projects: projects),
      ),
    );

    if (draft == null) {
      return;
    }

    if (task == null) {
      await onCreateTask(draft);
    } else {
      await onUpdateTask(
        draft.copyWith(id: task.id, createdAt: task.createdAt),
      );
    }
  }

  Future<void> _openManualLogDialog(BuildContext context, Task task) async {
    final _ManualLogResult? result = await showDialog<_ManualLogResult>(
      context: context,
      builder: (BuildContext context) => const _ManualLogDialog(),
    );

    if (result == null) {
      return;
    }

    await onCreateManualTimeEntry(
      task,
      result.startedAt,
      result.endedAt,
      result.billable,
      result.notes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Task>> grouped = <String, List<Task>>{
      'todo': tasks.where((Task task) => task.status == 'todo').toList(),
      'in_progress': tasks
          .where((Task task) => task.status == 'in_progress')
          .toList(),
      'done': tasks.where((Task task) => task.status == 'done').toList(),
    };
    final bool isWide = MediaQuery.sizeOf(context).width >= 1100;
    final bool isMedium = MediaQuery.sizeOf(context).width >= 760;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New ticket'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            children: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.maxContentWidth,
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _DashboardHeader(
                        activeProjects: projects.length,
                        tasks: tasks,
                        onLogout: onLogout,
                      ),
                      const SizedBox(height: 24),
                      _FiltersPanel(
                        projects: projects,
                        searchController: searchController,
                        selectedProjectId: selectedProjectId,
                        selectedStatus: selectedStatus,
                        selectedPriority: selectedPriority,
                        onSearchChanged: onSearchChanged,
                        onProjectChanged: onProjectChanged,
                        onStatusChanged: onStatusChanged,
                        onPriorityChanged: onPriorityChanged,
                      ),
                      const SizedBox(height: 18),
                      _TimelineSummary(tasks: tasks),
                      const SizedBox(height: 24),
                      if (errorMessage != null)
                        _ErrorBanner(message: errorMessage!)
                      else if (isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (tasks.isEmpty)
                        const _EmptyBoard()
                      else
                        isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: _BoardColumn(
                                      title: 'Backlog',
                                      subtitle: 'Ready to plan',
                                      icon: Icons.grid_view_rounded,
                                      tasks: grouped['todo']!,
                                      timeEntries: timeEntries,
                                      onEdit: (Task task) =>
                                          _openTaskForm(context, task: task),
                                      onDelete: onDeleteTask,
                                      onStartWork: onStartWork,
                                      onStopWork: onStopWork,
                                      onAddLog: (Task task) =>
                                          _openManualLogDialog(context, task),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: _BoardColumn(
                                      title: 'In progress',
                                      subtitle: 'Currently shipping',
                                      icon: Icons.run_circle_outlined,
                                      tasks: grouped['in_progress']!,
                                      timeEntries: timeEntries,
                                      onEdit: (Task task) =>
                                          _openTaskForm(context, task: task),
                                      onDelete: onDeleteTask,
                                      onStartWork: onStartWork,
                                      onStopWork: onStopWork,
                                      onAddLog: (Task task) =>
                                          _openManualLogDialog(context, task),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: _BoardColumn(
                                      title: 'Done',
                                      subtitle: 'Delivered recently',
                                      icon: Icons.task_alt_rounded,
                                      tasks: grouped['done']!,
                                      timeEntries: timeEntries,
                                      onEdit: (Task task) =>
                                          _openTaskForm(context, task: task),
                                      onDelete: onDeleteTask,
                                      onStartWork: onStartWork,
                                      onStopWork: onStopWork,
                                      onAddLog: (Task task) =>
                                          _openManualLogDialog(context, task),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: <Widget>[
                                  _BoardColumn(
                                    title: 'Backlog',
                                    subtitle: 'Ready to plan',
                                    icon: Icons.grid_view_rounded,
                                    tasks: grouped['todo']!,
                                    timeEntries: timeEntries,
                                    onEdit: (Task task) =>
                                        _openTaskForm(context, task: task),
                                    onDelete: onDeleteTask,
                                    onStartWork: onStartWork,
                                    onStopWork: onStopWork,
                                    onAddLog: (Task task) =>
                                        _openManualLogDialog(context, task),
                                  ),
                                  const SizedBox(height: 16),
                                  _BoardColumn(
                                    title: 'In progress',
                                    subtitle: 'Currently shipping',
                                    icon: Icons.run_circle_outlined,
                                    tasks: grouped['in_progress']!,
                                    timeEntries: timeEntries,
                                    onEdit: (Task task) =>
                                        _openTaskForm(context, task: task),
                                    onDelete: onDeleteTask,
                                    onStartWork: onStartWork,
                                    onStopWork: onStopWork,
                                    onAddLog: (Task task) =>
                                        _openManualLogDialog(context, task),
                                  ),
                                  const SizedBox(height: 16),
                                  _BoardColumn(
                                    title: 'Done',
                                    subtitle: 'Delivered recently',
                                    icon: Icons.task_alt_rounded,
                                    tasks: grouped['done']!,
                                    timeEntries: timeEntries,
                                    onEdit: (Task task) =>
                                        _openTaskForm(context, task: task),
                                    onDelete: onDeleteTask,
                                    onStartWork: onStartWork,
                                    onStopWork: onStopWork,
                                    onAddLog: (Task task) =>
                                        _openManualLogDialog(context, task),
                                  ),
                                ],
                              ),
                      if (isMedium) const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.activeProjects,
    required this.tasks,
    required this.onLogout,
  });

  final int activeProjects;
  final List<Task> tasks;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF0F172A),
            Color(0xFF17305B),
            Color(0xFF2E6CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
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
                      'TaskFlow board',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Project command board',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Run delivery across multiple projects, track ticket timelines, and keep the API-backed board aligned with what is actually shipping.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onLogout,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: <Widget>[
              _StatBadge(label: 'Projects', value: '$activeProjects'),
              _StatBadge(
                label: 'Backlog',
                value:
                    '${tasks.where((Task task) => task.status == 'todo').length}',
              ),
              _StatBadge(
                label: 'Doing',
                value:
                    '${tasks.where((Task task) => task.status == 'in_progress').length}',
              ),
              _StatBadge(
                label: 'Done',
                value:
                    '${tasks.where((Task task) => task.status == 'done').length}',
              ),
              _StatBadge(
                label: 'Avg lead',
                value: _formatHours(_averageLeadHours(tasks)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel({
    required this.projects,
    required this.searchController,
    required this.selectedProjectId,
    required this.selectedStatus,
    required this.selectedPriority,
    required this.onSearchChanged,
    required this.onProjectChanged,
    required this.onStatusChanged,
    required this.onPriorityChanged,
  });

  final List<Project> projects;
  final TextEditingController searchController;
  final String selectedProjectId;
  final String selectedStatus;
  final String selectedPriority;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onProjectChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPriorityChanged;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double itemWidth = width < 900
        ? double.infinity
        : math.max(220, (width - 120) / 4);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Board filters',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _filterChildren(itemWidth),
          ),
        ],
      ),
    );
  }

  List<Widget> _filterChildren(double itemWidth) {
    return <Widget>[
      SizedBox(
        width: itemWidth,
        child: TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            labelText: 'Search tickets',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: DropdownButtonFormField<String>(
          initialValue: selectedProjectId,
          decoration: const InputDecoration(labelText: 'Project'),
          items: <DropdownMenuItem<String>>[
            const DropdownMenuItem<String>(
              value: '',
              child: Text('All projects'),
            ),
            ...projects.map(
              (Project project) => DropdownMenuItem<String>(
                value: project.id.toString(),
                child: Text(project.name),
              ),
            ),
          ],
          onChanged: (String? value) => onProjectChanged(value ?? ''),
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: DropdownButtonFormField<String>(
          initialValue: selectedStatus,
          decoration: const InputDecoration(labelText: 'Status'),
          items: const <DropdownMenuItem<String>>[
            DropdownMenuItem<String>(value: '', child: Text('All statuses')),
            DropdownMenuItem<String>(value: 'todo', child: Text('Todo')),
            DropdownMenuItem<String>(
              value: 'in_progress',
              child: Text('In progress'),
            ),
            DropdownMenuItem<String>(value: 'done', child: Text('Done')),
          ],
          onChanged: (String? value) => onStatusChanged(value ?? ''),
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: DropdownButtonFormField<String>(
          initialValue: selectedPriority,
          decoration: const InputDecoration(labelText: 'Priority'),
          items: const <DropdownMenuItem<String>>[
            DropdownMenuItem<String>(value: '', child: Text('All priorities')),
            DropdownMenuItem<String>(value: 'low', child: Text('Low')),
            DropdownMenuItem<String>(value: 'medium', child: Text('Medium')),
            DropdownMenuItem<String>(value: 'high', child: Text('High')),
          ],
          onChanged: (String? value) => onPriorityChanged(value ?? ''),
        ),
      ),
    ];
  }
}

class _TimelineSummary extends StatelessWidget {
  const _TimelineSummary({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: AppConstants.taskPriorities.map((String priority) {
        final List<Task> scoped = tasks
            .where((Task task) => task.priority == priority)
            .toList();
        return _MetricCard(
          title: '${_label(priority)} priority',
          primaryValue: _formatHours(_averageCycleHours(scoped)),
          secondaryValue: 'Avg cycle',
          tertiaryValue: '${scoped.length} tickets',
        );
      }).toList(),
    );
  }

  String _label(String value) => value[0].toUpperCase() + value.substring(1);
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.primaryValue,
    required this.secondaryValue,
    required this.tertiaryValue,
  });

  final String title;
  final String primaryValue;
  final String secondaryValue;
  final String tertiaryValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            primaryValue,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            secondaryValue,
            style: TextStyle(color: Colors.blueGrey.shade700),
          ),
          const SizedBox(height: 10),
          Text(
            tertiaryValue,
            style: TextStyle(color: Colors.blueGrey.shade500),
          ),
        ],
      ),
    );
  }
}

class _BoardColumn extends StatelessWidget {
  const _BoardColumn({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tasks,
    required this.timeEntries,
    required this.onEdit,
    required this.onDelete,
    required this.onStartWork,
    required this.onStopWork,
    required this.onAddLog,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Task> tasks;
  final List<TimeEntry> timeEntries;
  final ValueChanged<Task> onEdit;
  final Future<void> Function(Task task) onDelete;
  final Future<void> Function(Task task) onStartWork;
  final Future<void> Function(Task task) onStopWork;
  final Future<void> Function(Task task) onAddLog;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.blueGrey.shade700),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE8EEF9),
                child: Text('${tasks.length}'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (tasks.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FD),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text('No tickets in this column.'),
            )
          else
            ...tasks.map((Task task) {
              final List<TimeEntry> activeEntries =
                  timeEntries
                      .where(
                        (TimeEntry entry) =>
                            entry.taskId == task.id && entry.isOpen,
                      )
                      .toList()
                    ..sort(
                      (TimeEntry left, TimeEntry right) =>
                          right.startedAt.compareTo(left.startedAt),
                    );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TaskCard(
                  task: task,
                  activeEntry: activeEntries.isEmpty
                      ? null
                      : activeEntries.first,
                  onEdit: () => onEdit(task),
                  onDelete: () => onDelete(task),
                  onStartWork: () => onStartWork(task),
                  onStopWork: () => onStopWork(task),
                  onAddLog: () => onAddLog(task),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(message, style: TextStyle(color: Colors.red.shade700)),
    );
  }
}

class _EmptyBoard extends StatelessWidget {
  const _EmptyBoard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        children: <Widget>[
          Icon(Icons.dashboard_customize_outlined, size: 42),
          SizedBox(height: 12),
          Text(
            'No tickets match these filters.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text('Create a ticket or widen the board filters.'),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

double _averageLeadHours(List<Task> tasks) {
  final List<double> values = tasks
      .where((Task task) => task.completedAt != null)
      .map(
        (Task task) =>
            task.completedAt!.difference(task.createdAt).inMinutes.toDouble() /
            60,
      )
      .toList();

  if (values.isEmpty) {
    return 0;
  }

  return values.reduce((double a, double b) => a + b) / values.length;
}

double _averageCycleHours(List<Task> tasks) {
  final List<double> values = tasks
      .where((Task task) => task.startedAt != null && task.completedAt != null)
      .map(
        (Task task) =>
            task.completedAt!.difference(task.startedAt!).inMinutes.toDouble() /
            60,
      )
      .toList();

  if (values.isEmpty) {
    return 0;
  }

  return values.reduce((double a, double b) => a + b) / values.length;
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

String _formatDateTime(DateTime value) {
  return '${value.day}/${value.month}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

class _ManualLogResult {
  const _ManualLogResult({
    required this.startedAt,
    required this.endedAt,
    required this.billable,
    required this.notes,
  });

  final DateTime startedAt;
  final DateTime endedAt;
  final bool billable;
  final String? notes;
}

class _ManualLogDialog extends StatefulWidget {
  const _ManualLogDialog();

  @override
  State<_ManualLogDialog> createState() => _ManualLogDialogState();
}

class _ManualLogDialogState extends State<_ManualLogDialog> {
  late DateTime _startedAt;
  late DateTime _endedAt;
  bool _billable = true;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _endedAt = DateTime.now();
    _startedAt = _endedAt.subtract(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({
    required DateTime current,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null || !mounted) {
      return;
    }

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );

    if (time == null) {
      return;
    }

    onPicked(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add manual work log'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Started'),
              subtitle: Text(_formatDateTime(_startedAt)),
              trailing: const Icon(Icons.calendar_month_rounded),
              onTap: () => _pickDateTime(
                current: _startedAt,
                onPicked: (DateTime value) {
                  setState(() {
                    _startedAt = value;
                  });
                },
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ended'),
              subtitle: Text(_formatDateTime(_endedAt)),
              trailing: const Icon(Icons.calendar_month_rounded),
              onTap: () => _pickDateTime(
                current: _endedAt,
                onPicked: (DateTime value) {
                  setState(() {
                    _endedAt = value;
                  });
                },
              ),
            ),
            SwitchListTile(
              value: _billable,
              onChanged: (bool value) {
                setState(() {
                  _billable = value;
                });
              },
              title: const Text('Billable'),
              contentPadding: EdgeInsets.zero,
            ),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_endedAt.isBefore(_startedAt)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ended time must be after the started time.'),
                ),
              );
              return;
            }

            Navigator.of(context).pop(
              _ManualLogResult(
                startedAt: _startedAt,
                endedAt: _endedAt,
                billable: _billable,
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
