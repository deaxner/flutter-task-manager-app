import 'package:flutter/material.dart';
import 'package:flutter_task_manager_app/models/task.dart';
import 'package:flutter_task_manager_app/utils/constants.dart';
import 'package:flutter_task_manager_app/widgets/custom_button.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({
    super.key,
    this.initialTask,
  });

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
  DateTime? _dueDate;

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
    _priority =
        widget.initialTask?.priority ?? AppConstants.taskPriorities[1];
    _dueDate = widget.initialTask?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime initial = _dueDate ?? now;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _dueDate = DateTime(picked.year, picked.month, picked.day, 9);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      Task(
        id: widget.initialTask?.id ?? 0,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        status: _status,
        priority: _priority,
        dueDate: _dueDate,
        createdAt: widget.initialTask?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Create Task'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  items: AppConstants.taskStatuses
                      .map(
                        (String status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(status.replaceAll('_', ' ')),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  items: AppConstants.taskPriorities
                      .map(
                        (String priority) => DropdownMenuItem<String>(
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
                  decoration: const InputDecoration(labelText: 'Priority'),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(20),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      suffixIcon: Icon(Icons.calendar_month_rounded),
                    ),
                    child: Text(
                      _dueDate == null
                          ? 'No due date selected'
                          : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                    ),
                  ),
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
                        label: isEditing ? 'Save Changes' : 'Create Task',
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
    );
  }
}
