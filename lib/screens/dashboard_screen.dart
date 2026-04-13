import 'package:flutter/material.dart';
import 'package:flutter_task_manager_app/models/task.dart';
import 'package:flutter_task_manager_app/screens/task_form_screen.dart';
import 'package:flutter_task_manager_app/widgets/task_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.tasks,
    required this.isLoading,
    required this.errorMessage,
    required this.searchController,
    required this.selectedStatus,
    required this.selectedPriority,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onRefresh,
    required this.onLogout,
    required this.onCreateTask,
    required this.onUpdateTask,
    required this.onDeleteTask,
  });

  final List<Task> tasks;
  final bool isLoading;
  final String? errorMessage;
  final TextEditingController searchController;
  final String selectedStatus;
  final String selectedPriority;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPriorityChanged;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;
  final Future<void> Function(Task draft) onCreateTask;
  final Future<void> Function(Task draft) onUpdateTask;
  final Future<void> Function(Task task) onDeleteTask;

  Future<void> _openTaskForm(BuildContext context, {Task? task}) async {
    final Task? draft = await Navigator.of(context).push<Task>(
      MaterialPageRoute<Task>(
        builder: (_) => TaskFormScreen(initialTask: task),
      ),
    );

    if (draft == null) {
      return;
    }

    if (task == null) {
      await onCreateTask(draft);
    } else {
      await onUpdateTask(draft.copyWith(id: task.id, createdAt: task.createdAt));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Dashboard'),
        actions: <Widget>[
          IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Task'),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: <Widget>[
            Text(
              'Your task flow',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track tasks coming from the Symfony backend, filter fast, and manage your queue from mobile.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.blueGrey.shade700,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search tasks',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text('All'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'todo',
                        child: Text('Todo'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'in_progress',
                        child: Text('In progress'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'done',
                        child: Text('Done'),
                      ),
                    ],
                    onChanged: (String? value) => onStatusChanged(value ?? ''),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedPriority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text('All'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'low',
                        child: Text('Low'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'medium',
                        child: Text('Medium'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'high',
                        child: Text('High'),
                      ),
                    ],
                    onChanged: (String? value) => onPriorityChanged(value ?? ''),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (tasks.isEmpty)
              Container(
                margin: const EdgeInsets.only(top: 30),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Column(
                  children: <Widget>[
                    Icon(Icons.inbox_outlined, size: 42),
                    SizedBox(height: 12),
                    Text(
                      'No tasks found.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                    Text('Create a task or change the active filters.'),
                  ],
                ),
              )
            else
              ...tasks.map(
                (Task task) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TaskCard(
                    task: task,
                    onEdit: () => _openTaskForm(context, task: task),
                    onDelete: () => onDeleteTask(task),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
