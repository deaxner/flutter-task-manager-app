import 'package:flutter/material.dart';
import 'package:flutter_task_manager_app/models/project.dart';
import 'package:flutter_task_manager_app/models/task.dart';
import 'package:flutter_task_manager_app/utils/constants.dart';
import 'package:flutter_task_manager_app/widgets/custom_button.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, required this.projects, this.initialTask});

  final List<Project> projects;
  final Task? initialTask;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _status;
  late String _priority;
  late Project _project;
  DateTime? _dueDate;
  DateTime? _startedAt;
  DateTime? _completedAt;

  bool get isEditing => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialTask?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialTask?.description ?? '',
    );
    _status = widget.initialTask?.status ?? AppConstants.taskStatuses.first;
    _priority = widget.initialTask?.priority ?? AppConstants.taskPriorities[1];
    _project = widget.initialTask?.project ?? widget.projects.first;
    _dueDate = widget.initialTask?.dueDate;
    _startedAt = widget.initialTask?.startedAt;
    _completedAt = widget.initialTask?.completedAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime? currentValue,
    required ValueChanged<DateTime?> onChanged,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime initial = currentValue ?? now;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    final TimeOfDay initialTime = TimeOfDay.fromDateTime(currentValue ?? now);
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime == null) {
      return;
    }

    onChanged(
      DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      ),
    );
  }

  void _syncTimelineForStatus(String status) {
    if (status == 'todo') {
      _startedAt = null;
      _completedAt = null;
      return;
    }

    _startedAt ??= DateTime.now();
    if (status != 'done') {
      _completedAt = null;
      return;
    }

    _completedAt ??= DateTime.now();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_completedAt != null &&
        _startedAt != null &&
        _completedAt!.isBefore(_startedAt!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completed time must be after the started time.'),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      Task(
        id: widget.initialTask?.id ?? 0,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        project: _project,
        status: _status,
        priority: _priority,
        dueDate: _dueDate,
        startedAt: _startedAt,
        completedAt: _completedAt,
        totalLoggedMinutes: widget.initialTask?.totalLoggedMinutes ?? 0,
        billableMinutes: widget.initialTask?.billableMinutes ?? 0,
        timeEntriesCount: widget.initialTask?.timeEntriesCount ?? 0,
        createdAt: widget.initialTask?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit ticket' : 'Create ticket')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          isEditing
                              ? 'Update workflow ticket'
                              : 'Add workflow ticket',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Assign the ticket to a project, set its board state, and capture the actual execution timeline.',
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Title is required.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Project>(
                          initialValue: _project,
                          decoration: const InputDecoration(
                            labelText: 'Project',
                          ),
                          items: widget.projects
                              .map(
                                (Project project) => DropdownMenuItem<Project>(
                                  value: project,
                                  child: Text(project.name),
                                ),
                              )
                              .toList(),
                          onChanged: (Project? value) {
                            if (value != null) {
                              setState(() {
                                _project = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _status,
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                ),
                                items: AppConstants.taskStatuses
                                    .map(
                                      (String status) =>
                                          DropdownMenuItem<String>(
                                            value: status,
                                            child: Text(
                                              status.replaceAll('_', ' '),
                                            ),
                                          ),
                                    )
                                    .toList(),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    setState(() {
                                      _status = value;
                                      _syncTimelineForStatus(value);
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _priority,
                                decoration: const InputDecoration(
                                  labelText: 'Priority',
                                ),
                                items: AppConstants.taskPriorities
                                    .map(
                                      (String priority) =>
                                          DropdownMenuItem<String>(
                                            value: priority,
                                            child: Text(priority),
                                          ),
                                    )
                                    .toList(),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    setState(() {
                                      _priority = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _DateField(
                                label: 'Due date',
                                value: _dueDate,
                                onPressed: () => _pickDate(
                                  currentValue: _dueDate,
                                  onChanged: (DateTime? value) {
                                    setState(() {
                                      _dueDate = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DateField(
                                label: 'Started',
                                value: _startedAt,
                                onPressed: () => _pickDate(
                                  currentValue: _startedAt,
                                  onChanged: (DateTime? value) {
                                    setState(() {
                                      _startedAt = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DateField(
                                label: 'Completed',
                                value: _completedAt,
                                onPressed: () => _pickDate(
                                  currentValue: _completedAt,
                                  onChanged: (DateTime? value) {
                                    setState(() {
                                      _completedAt = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                label: isEditing
                                    ? 'Save changes'
                                    : 'Create ticket',
                                icon: isEditing
                                    ? Icons.save_outlined
                                    : Icons.add_task_rounded,
                                onPressed: _submit,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_month_rounded),
        ),
        child: Text(
          value == null
              ? 'Not set'
              : '${value!.day}/${value!.month}/${value!.year} ${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }
}
