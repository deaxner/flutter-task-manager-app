# Flutter Task Manager App

Clean Flutter task manager client for the Symfony task API in the portfolio suite.

## Features

- Login screen with API authentication
- Task list with search and filtering
- Create, edit, and delete tasks
- Symfony backend integration with JWT token handling
- Form validation and user-facing error handling
- Reusable widgets with separated UI, models, services, and utils

## Stack

- Flutter
- Dart
- HTTP API integration
- Simple state management with `setState`
- Dockerized Flutter web preview with Nginx

## Folder Structure

```text
flutter-task-manager-app/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── task.dart
│   ├── screens/
│   │   ├── dashboard_screen.dart
│   │   ├── login_screen.dart
│   │   └── task_form_screen.dart
│   ├── services/
│   │   └── api_service.dart
│   ├── utils/
│   │   └── constants.dart
│   └── widgets/
│       ├── custom_button.dart
│       └── task_card.dart
├── docker/
│   └── nginx/
│       └── default.conf
├── Dockerfile
├── compose.yaml
├── docker-up.ps1
├── pubspec.yaml
└── README.md
```

## Key Screens

- `LoginScreen`: authenticates against the Symfony backend and handles login validation and API errors
- `DashboardScreen`: displays tasks, supports pull-to-refresh, search, status filtering, priority filtering, and logout
- `TaskFormScreen`: creates or edits task details with validation and due date picker

## API Service Example

The app uses `lib/services/api_service.dart` to handle authentication and task requests.

```dart
final api = ApiService();
await api.login(email: 'alice@example.com', password: 'Password123');
final tasks = await api.fetchTasks(status: 'todo', search: 'report');
```

## Backend Connection

By default the app targets:

```text
http://localhost:8002/api
```

Override it at run time:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8002/api
```

Override it for Docker web builds:

```bash
docker compose build --build-arg API_BASE_URL=http://localhost:8002/api
```

Use `10.0.2.2` for Android emulator access to a backend running on your host machine.

## Local Flutter Setup

1. Make sure the Symfony backend is running.
2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## Docker Web Preview

This repo includes a Dockerized Flutter web build for recruiter-friendly local preview.

### Start with default port

```bash
docker compose up --build -d
```

Default web port:

```text
http://localhost:8080
```

### Start with automatic port fallback on Windows

```powershell
./docker-up.ps1
```

The script prefers port `8080`. If it is already in use, it falls back to the next free port up to `8180`.

### Stop the web container

```bash
docker compose down
```

## Symfony Backend Notes

This app expects the following backend endpoints:

- `POST /api/login`
- `GET /api/tasks`
- `POST /api/tasks`
- `PUT /api/tasks/{id}`
- `DELETE /api/tasks/{id}`

## Responsive UI Notes

- The login screen uses a centered constrained layout for larger screens
- The dashboard uses adaptive spacing and scrollable layouts for smaller devices
- The same Flutter codebase can target mobile and web
