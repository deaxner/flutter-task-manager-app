import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'TaskFlow Board';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8002/api',
  );

  static const List<String> taskStatuses = <String>[
    'todo',
    'in_progress',
    'done',
  ];

  static const List<String> taskPriorities = <String>['low', 'medium', 'high'];

  static const Color primaryColor = Color(0xFF0F172A);
  static const Color accentColor = Color(0xFF57B6FF);
  static const Color surfaceColor = Color(0xFFF3F6FC);
  static const double maxContentWidth = 1320;
}
