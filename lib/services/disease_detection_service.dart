import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';

class DiseaseDetectionService {
  static String get baseUrl {
    const bool isDev = !bool.fromEnvironment('dart.vm.product');
    if (isDev) {
      if (kIsWeb) {
        return 'http://localhost:8000';
      }
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000';
      }
      return 'http://localhost:8000';
    } else {
      return AppConfig.baseUrl;
    }
  }

  /// Detects plant disease from an image file (cross-platform)
  static Future<Map<String, dynamic>> detectDisease(XFile imageFile,
      {bool mobile = !kIsWeb}) async {
    try {
      final uri = Uri.parse('$baseUrl/predict');
      final request = http.MultipartRequest('POST', uri)
        ..fields['mobile'] = mobile.toString();

      final bytes = await imageFile.readAsBytes();
      final fileSize = bytes.length;

      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        throw Exception(
            'Image file is too large: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB. Maximum size is 10MB.');
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Server returned error ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error in detectDisease: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to analyze image: $e');
    }
  }

  /// Gets remedies for a specific disease
  static Future<List<String>> getRemedies(String disease,
      {String language = 'en'}) async {
    try {
      // CORRECTED ENDPOINT with language parameter
      final response = await http.get(
        Uri.parse('$baseUrl/recommend/$disease?language=$language'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['remedies'] ?? []);
      } else if (response.statusCode == 404) {
        // Disease not found in remedies database, return generic advice
        return [
          'Consult with a local agricultural expert for specific treatment',
          'Remove affected plant parts if visible disease symptoms present',
          'Ensure proper plant nutrition and watering',
          'Consider applying appropriate fungicide if fungal disease suspected',
          'Monitor plant regularly and maintain good garden hygiene'
        ];
      } else {
        throw Exception('Failed to get remedies: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getRemedies: $e');
      // Return generic advice instead of throwing error
      return [
        'Unable to fetch specific remedies at this time',
        'Consult with a local agricultural expert',
        'Maintain good plant care practices',
        'Monitor the plant for changes'
      ];
    }
  }

  /// Gets available model versions
  static Future<Map<String, dynamic>> getModelVersions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/model_versions'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get model versions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting model versions: $e');
    }
  }
}
