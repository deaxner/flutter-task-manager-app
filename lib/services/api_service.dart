import 'dart:convert';

import 'package:flutter_task_manager_app/models/project.dart';
import 'package:flutter_task_manager_app/models/task.dart';
import 'package:flutter_task_manager_app/models/time_entry.dart';
import 'package:flutter_task_manager_app/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  static const String _tokenKey = 'auth_token';

  final http.Client _client;
  String? _token;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> restoreSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> login({required String email, required String password}) async {
    final http.Response response = await _client.post(
      _uri('/login'),
      headers: _headers(),
      body: jsonEncode(<String, dynamic>{'email': email, 'password': password}),
    );

    final Map<String, dynamic> payload = _decode(response);
    if (response.statusCode != 200) {
      throw ApiException(payload['message'] as String? ?? 'Login failed.');
    }

    final String? token =
        (payload['data'] as Map<String, dynamic>?)?['token'] as String?;
    if (token == null || token.isEmpty) {
      throw ApiException('Login succeeded but no token was returned.');
    }

    _token = token;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> logout() async {
    _token = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<List<Project>> fetchProjects() async {
    final http.Response response = await _client.get(
      _uri('/projects'),
      headers: _headers(includeAuth: true),
    );

    final Map<String, dynamic> payload = _decode(response);
    if (response.statusCode != 200) {
      throw ApiException(
        payload['message'] as String? ?? 'Unable to fetch projects.',
      );
    }

    final List<dynamic> data = payload['data'] as List<dynamic>? ?? <dynamic>[];
    return data
        .map((dynamic item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Task>> fetchTasks({
    String? status,
    String? priority,
    int? projectId,
    String? search,
  }) async {
    final Map<String, dynamic> query = <String, dynamic>{
      'page': '1',
      'limit': '20',
      'sort': 'createdAt',
      'direction': 'desc',
      if (status != null && status.isNotEmpty) 'status': status,
      if (priority != null && priority.isNotEmpty) 'priority': priority,
      if (projectId != null) 'projectId': projectId,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    final http.Response response = await _client.get(
      _uri('/tasks', query),
      headers: _headers(includeAuth: true),
    );

    final Map<String, dynamic> payload = _decode(response);
    if (response.statusCode != 200) {
      throw ApiException(
        payload['message'] as String? ?? 'Unable to fetch tasks.',
      );
    }

    final List<dynamic> data = payload['data'] as List<dynamic>? ?? <dynamic>[];
    return data
        .map((dynamic item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Task> createTask(Task task) async {
    final http.Response response = await _client.post(
      _uri('/tasks'),
      headers: _headers(includeAuth: true),
      body: jsonEncode(task.toRequestJson()),
    );

    final Map<String, dynamic> payload = _decode(response);
    if (response.statusCode != 201) {
      throw ApiException(
        payload['message'] as String? ?? 'Unable to create task.',
      );
    }

    return Task.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<Task> updateTask(Task task) async {
    final http.Response response = await _client.put(
      _uri('/tasks/${task.id}'),
      headers: _headers(includeAuth: true),
      body: jsonEncode(task.toRequestJson()),
    );

    final Map<String, dynamic> payload = _decode(response);
    if (response.statusCode != 200) {
      throw ApiException(
        payload['message'] as String? ?? 'Unable to update task.',
      );
    }

    return Task.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<List<TimeEntry>> fetchTimeEntries({int? taskId}) async {
    final http.Response response = await _client.get(
      _uri('/time-entries', {if (taskId != null) 'taskId': taskId}),
      headers: _headers(includeAuth: true),
    );

    final Map<String, dynamic> payload = _decode(response);
    if (response.statusCode != 200) {
      throw ApiException(
        payload['message'] as String? ?? 'Unable to fetch time entries.',
      );
    }

    final List<dynamic> data = payload['data'] as List<dynamic>? ?? <dynamic>[];
    return data
        .map((dynamic item) => TimeEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TimeEntry> createTimeEntry(Map<String, dynamic> payloadBody) async {
    final http.Response response = await _client.post(
      _uri('/time-entries'),
      headers: _headers(includeAuth: true),
      body: jsonEncode(payloadBody),
    );

    final Map<String, dynamic> payload = _decode(response);
    if (response.statusCode != 201) {
      throw ApiException(
        payload['message'] as String? ?? 'Unable to create time entry.',
      );
    }

    return TimeEntry.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<TimeEntry> updateTimeEntry(
    int id,
    Map<String, dynamic> payloadBody,
  ) async {
    final http.Response response = await _client.put(
      _uri('/time-entries/$id'),
      headers: _headers(includeAuth: true),
      body: jsonEncode(payloadBody),
    );

    final Map<String, dynamic> payload = _decode(response);
    if (response.statusCode != 200) {
      throw ApiException(
        payload['message'] as String? ?? 'Unable to update time entry.',
      );
    }

    return TimeEntry.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<void> deleteTask(int id) async {
    final http.Response response = await _client.delete(
      _uri('/tasks/$id'),
      headers: _headers(includeAuth: true),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> payload = _decode(response);
      throw ApiException(
        payload['message'] as String? ?? 'Unable to delete task.',
      );
    }
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final Uri base = Uri.parse(AppConstants.apiBaseUrl);
    final String normalizedPath =
        '${base.path.endsWith('/') ? base.path.substring(0, base.path.length - 1) : base.path}$path';

    return base.replace(
      path: normalizedPath,
      queryParameters: query?.map(
        (String key, dynamic value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Map<String, String> _headers({bool includeAuth = false}) {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (includeAuth && _token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    final dynamic payload = jsonDecode(response.body);
    if (payload is Map<String, dynamic>) {
      return payload;
    }

    return <String, dynamic>{};
  }
}
