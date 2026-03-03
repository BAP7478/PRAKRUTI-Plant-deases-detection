import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late http.Client _client;
  bool _isInitialized = false;

  // Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;
    _client = http.Client();
    _isInitialized = true;
    if (AppConfig.enableLogging) {
      print('🌱 ApiService initialized with base URL: $baseUrl');
    }
  }

  // Base URL with platform detection for backend connection
  static String get baseUrl {
    // Check if we're running in development mode
    const bool isDev = !bool.fromEnvironment('dart.vm.product');

    if (isDev) {
      // Check if running on web platform
      if (kIsWeb) {
        return 'http://localhost:8000'; // Web platform - UPDATED PORT
      }
      // For mobile platforms, use Platform check safely
      try {
        if (Platform.isAndroid) {
          return 'http://10.0.2.2:8000'; // For Android emulator - UPDATED PORT
        }
      } catch (e) {
        // Fallback for non-Android mobile or other platforms
      }
      return 'http://localhost:8000'; // For iOS simulator and other platforms - UPDATED PORT
    } else {
      return AppConfig.baseUrl; // Use production URL from config
    }
  }

  // Check if backend is running
  Future<bool> checkHealth() async {
    try {
      if (!_isInitialized) await initialize();
      final response = await _client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(Duration(milliseconds: AppConfig.connectionTimeout));
      if (AppConfig.enableLogging) {
        print('🏥 Health check response: ${response.statusCode}');
      }
      return response.statusCode == 200;
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Health check failed: $e');
      }
      return false;
    }
  }

  // Wait for backend to be available with retries
  Future<bool> waitForBackend(
      {int maxAttempts = 5, int delaySeconds = 2}) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      if (AppConfig.enableLogging) {
        print(
            '🔍 Checking backend availability (attempt $attempt/$maxAttempts)...');
      }
      if (await checkHealth()) {
        if (AppConfig.enableLogging) {
          print('✅ Backend is available!');
        }
        return true;
      }
      if (attempt < maxAttempts) {
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }
    if (AppConfig.enableLogging) {
      print('❌ Backend not available after $maxAttempts attempts');
    }
    return false;
  }

  // Predict plant disease from image
  Future<Map<String, dynamic>> predictDisease(XFile imageFile) async {
    try {
      if (!_isInitialized) await initialize();
      var uri = Uri.parse('$baseUrl/predict');
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'User-Agent': '${AppConfig.appName}/${AppConfig.version}',
      });

      final bytes = await imageFile.readAsBytes();
      final length = bytes.length;

      // Check file size
      if (length > AppConfig.maxFileSize) {
        throw Exception(
            'File size too large. Maximum allowed: ${AppConfig.maxFileSize ~/ (1024 * 1024)}MB');
      }

      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name,
      );
      request.files.add(multipartFile);

      // Send the request with timeout
      var response = await request.send().timeout(
            Duration(milliseconds: AppConfig.receiveTimeout),
          );
      var responseData = await response.stream.bytesToString();
      var result = json.decode(responseData);

      if (AppConfig.enableLogging) {
        print('📸 Disease prediction -> ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return result;
      } else {
        throw Exception(
            'Failed to predict disease: ${result['error'] ?? result['detail'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Error predicting disease: $e');
      }
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Get remedies for a disease
  Future<Map<String, dynamic>> getRemedies(String disease,
      {String language = 'en'}) async {
    try {
      if (!_isInitialized) await initialize();
      final response = await _client.get(
        Uri.parse(
            '$baseUrl/recommend/${Uri.encodeComponent(disease)}?language=$language'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': '${AppConfig.appName}/${AppConfig.version}',
        },
      ).timeout(Duration(milliseconds: AppConfig.receiveTimeout));

      if (AppConfig.enableLogging) {
        print('💊 Remedies request -> ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get remedies: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Error getting remedies: $e');
      }
      return {
        'error': 'Failed to fetch remedies. Please try again later.',
      };
    }
  }

  // Get weather information
  Future<Map<String, dynamic>> getWeather(String location) async {
    try {
      if (!_isInitialized) await initialize();
      final response = await _client.get(
        Uri.parse('$baseUrl/weather?location=${Uri.encodeComponent(location)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': '${AppConfig.appName}/${AppConfig.version}',
        },
      ).timeout(Duration(milliseconds: AppConfig.receiveTimeout));

      if (AppConfig.enableLogging) {
        print('🌤️ Weather request -> ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get weather: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Error getting weather: $e');
      }
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Get model versions
  Future<Map<String, dynamic>> getModelVersions() async {
    try {
      if (!_isInitialized) await initialize();
      final response = await _client.get(
        Uri.parse('$baseUrl/model_versions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': '${AppConfig.appName}/${AppConfig.version}',
        },
      ).timeout(Duration(milliseconds: AppConfig.receiveTimeout));

      if (AppConfig.enableLogging) {
        print('📊 Model versions request -> ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to get model versions: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Error getting model versions: $e');
      }
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Dispose of resources
  void dispose() {
    if (_isInitialized) {
      _client.close();
      _isInitialized = false;
      if (AppConfig.enableLogging) {
        print('🧹 ApiService disposed');
      }
    }
  }
}
