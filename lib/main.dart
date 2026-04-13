import 'package:flutter/material.dart';
import 'package:flutter_task_manager_app/models/task.dart';
import 'package:flutter_task_manager_app/screens/dashboard_screen.dart';
import 'package:flutter_task_manager_app/screens/login_screen.dart';
import 'package:flutter_task_manager_app/services/api_service.dart';
import 'package:flutter_task_manager_app/utils/constants.dart';

void main() {
  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatefulWidget {
  const TaskFlowApp({super.key});

  @override
  State<TaskFlowApp> createState() => _TaskFlowAppState();
}

class _TaskFlowAppState extends State<TaskFlowApp> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _booting = true;
  bool _loginLoading = false;
  bool _tasksLoading = false;
  String? _authError;
  String? _taskError;
  String _statusFilter = '';
  String _priorityFilter = '';
  List<Task> _tasks = <Task>[];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _apiService.restoreSession();

    if (_apiService.isAuthenticated) {
      await _loadTasks();
    }

    if (mounted) {
      setState(() {
        _booting = false;
      });
    }
  }

  Future<void> _login(String email, String password) async {
    setState(() {
      _loginLoading = true;
      _authError = null;
    });

    try {
      await _apiService.login(email: email, password: password);
      await _loadTasks();
    } on ApiException catch (error) {
      setState(() {
        _authError = error.message;
      });
    } catch (_) {
      setState(() {
        _authError = 'Unexpected login error. Check your API connection.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loginLoading = false;
        });
      }
    }
  }

  Future<void> _loadTasks() async {
    setState(() {
      _tasksLoading = true;
      _taskError = null;
    });

    try {
      final List<Task> tasks = await _apiService.fetchTasks(
        status: _statusFilter,
        priority: _priorityFilter,
        search: _searchController.text,
      );

      setState(() {
        _tasks = tasks;
      });
    } on ApiException catch (error) {
      setState(() {
        _taskError = error.message;
      });
    } catch (_) {
      setState(() {
        _taskError = 'Unexpected API error while loading tasks.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _tasksLoading = false;
        });
      }
    }
  }

  Future<void> _createTask(Task draft) async {
    try {
      await _apiService.createTask(draft);
      await _loadTasks();
    } on ApiException catch (error) {
      _showSnack(error.message);
    }
  }

  Future<void> _updateTask(Task draft) async {
    try {
      await _apiService.updateTask(draft);
      await _loadTasks();
    } on ApiException catch (error) {
      _showSnack(error.message);
    }
  }

  Future<void> _deleteTask(Task task) async {
    try {
      await _apiService.deleteTask(task.id);
      await _loadTasks();
      _showSnack('Task deleted.');
    } on ApiException catch (error) {
      _showSnack(error.message);
    }
  }

  Future<void> _logout() async {
    await _apiService.logout();
    setState(() {
      _tasks = <Task>[];
      _authError = null;
      _taskError = null;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.accentColor,
        primary: AppConstants.primaryColor,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppConstants.surfaceColor,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: AppConstants.surfaceColor,
      ),
    );

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: _booting
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _apiService.isAuthenticated
              ? DashboardScreen(
                  tasks: _tasks,
                  isLoading: _tasksLoading,
                  errorMessage: _taskError,
                  searchController: _searchController,
                  selectedStatus: _statusFilter,
                  selectedPriority: _priorityFilter,
                  onSearchChanged: (_) => _loadTasks(),
                  onStatusChanged: (String value) {
                    setState(() {
                      _statusFilter = value;
                    });
                    _loadTasks();
                  },
                  onPriorityChanged: (String value) {
                    setState(() {
                      _priorityFilter = value;
                    });
                    _loadTasks();
                  },
                  onRefresh: _loadTasks,
                  onLogout: _logout,
                  onCreateTask: _createTask,
                  onUpdateTask: _updateTask,
                  onDeleteTask: _deleteTask,
                )
              : LoginScreen(
                  isLoading: _loginLoading,
                  errorMessage: _authError,
                  onLogin: _login,
                ),
    );
  }
}
