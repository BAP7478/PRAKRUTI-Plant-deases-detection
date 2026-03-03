# Copilot Instructions for PRAKRUTI

## Project Overview
- **PRAKRUTI** is a multi-platform Flutter app (Android, iOS, macOS, web, Windows) for plant disease detection, remedies, weather, and community features.
- Main code is in `lib/` (e.g., `main.dart`, `loginpage.dart`). Platform-specific code is in `android/`, `ios/`, etc.
- Uses local authentication and backend API for services.

## Architecture & Data Flow
- **Entry Point:** `main.dart` initializes cameras and sets up routing.
- **Routing:** Uses named routes in `MaterialApp` (e.g., `/` for login, `/app` for main app, `/community`, `/chatbot`, etc.).
- **Screens:** Each major feature (community, chatbot, profile, soil analysis, weather, shop) is a separate screen class, typically referenced in routes.
- **Services:** Disease remedies, weather, and ML prediction logic are in service classes in `main.dart`.
- **Authentication:** Simple local authentication handled in `loginpage.dart` using demo credentials.

## Developer Workflows
- **Build:**
  - Run `flutter pub get` to fetch dependencies.
  - Use `flutter run` to launch the app (choose device/platform as prompted).
- **Backend Setup:**
  - Backend is in `prakruti-backend/` directory with AI disease detection API.
  - Use `python3 -m uvicorn app_enhanced:app --reload --host 0.0.0.0 --port 8002` to start backend.
- **Testing:**
  - Widget tests are in `test/` (e.g., `widget_test.dart`).
- **Debugging:**
  - Common errors: missing methods, unmatched brackets, undefined routes/screens.
  - Check for missing or misnamed widgets in route definitions.

## Project-Specific Patterns
- **Service Classes:** Disease, weather, and ML logic are grouped as static classes in `main.dart`.
- **Screen Navigation:** Always use named routes for navigation (e.g., `Navigator.of(context).pushReplacementNamed('/app')`).
- **Platform Support:** All platforms are supported; check platform-specific folders for configuration.
- **Backend Integration:** Always ensure backend is running before testing API-dependent features.

## Integration Points
- **External Dependencies:**
  - `camera`, `http`, `image_picker`, etc. (see `pubspec.yaml`).
  - Backend API must be running for disease detection and other services.
- **Cross-Component Communication:**
  - Data/services are passed via constructors or static methods.
  - Screens communicate via named routes and context.

## Key Files & Directories
- `lib/main.dart`: App entry, routing, service classes.
- `lib/loginpage.dart`: Login/sign-up logic.
- `pubspec.yaml`: Dependency management.
- `test/`: Widget tests.
- `android/`, `ios/`, `macos/`, `web/`, `windows/`: Platform-specific code.

## Example Patterns
- **Route Definition:**
  ```dart
  MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const LoginScreen(),
      '/app': (context) => PrakrutiApp(cameras: _cameras),
      // ...other routes
    },
  )
  ```
- **Service Usage:**
  ```dart
  final weather = await WeatherService.getCurrentWeather(location);
  ```

---

**If any section is unclear or missing, please provide feedback so instructions can be improved for your team.**
