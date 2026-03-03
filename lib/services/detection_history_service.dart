import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/detection.dart';

class DetectionHistoryService {
  static const String _storageKey = 'detection_history';

  // Add a new detection to history
  static Future<void> addDetection(Detection detection) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_storageKey) ?? [];

    historyJson.insert(
        0, jsonEncode(detection.toJson())); // Add to start of list

    // Limit history to last 50 items
    if (historyJson.length > 50) {
      historyJson.removeLast();
    }

    await prefs.setStringList(_storageKey, historyJson);
  }

  // Get all detections
  static Future<List<Detection>> getDetections() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_storageKey) ?? [];

    return historyJson
        .map((json) => Detection.fromJson(jsonDecode(json)))
        .toList();
  }

  // Clear all history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // Remove a specific detection
  static Future<void> removeDetection(Detection detection) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_storageKey) ?? [];

    historyJson.removeWhere((json) {
      final item = Detection.fromJson(jsonDecode(json));
      return item.dateTime == detection.dateTime &&
          item.imagePath == detection.imagePath;
    });

    await prefs.setStringList(_storageKey, historyJson);
  }
}
