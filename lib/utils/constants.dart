import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'TaskFlow Mobile';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8002/api',
  );

  static const List<String> taskStatuses = <String>[
    'todo',
    'in_progress',
    'done',
  ];

  static const List<String> taskPriorities = <String>[
    'low',
    'medium',
    'high',
  ];

  static const Color primaryColor = Color(0xFF0F172A);
  static const Color accentColor = Color(0xFF14B8A6);
  static const Color surfaceColor = Color(0xFFF8FAFC);
  static const double maxContentWidth = 720;
}
