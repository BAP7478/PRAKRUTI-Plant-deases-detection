import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  // Convert message to JSON
  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  // Create message from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'],
        isUser: json['isUser'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class ChatService {
  static const String baseUrl =
      'http://localhost:8000'; // Backend URL - UPDATED PORT
  final SharedPreferences _prefs;
  final _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isConnected = true;

  ChatService._(this._prefs) {
    _initConnectivity();
  }

  static Future<ChatService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ChatService._(prefs);
  }

  void _initConnectivity() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      _isConnected = result != ConnectivityResult.none;
    });
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
  }

  // Save messages to local storage
  Future<void> saveMessages(List<ChatMessage> messages) async {
    final messagesJson = messages.map((msg) => msg.toJson()).toList();
    await _prefs.setString('chat_messages', json.encode(messagesJson));
  }

  // Load messages from local storage
  Future<List<ChatMessage>> loadMessages() async {
    final String? messagesJson = _prefs.getString('chat_messages');
    if (messagesJson == null) return [];

    final List<dynamic> decoded = json.decode(messagesJson);
    return decoded.map((msg) => ChatMessage.fromJson(msg)).toList();
  }

  // Get AI response from backend
  Future<String> getAIResponse(String userMessage) async {
    if (!_isConnected) {
      throw Exception('No internet connection');
    }

    try {
      // Create persistent conversation ID based on current date
      final conversationId =
          'chat_${DateTime.now().toString().substring(0, 10)}';

      final response = await http
          .post(
            Uri.parse('$baseUrl/chat'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'message': userMessage,
              'conversation_id': conversationId,
              'language': 'auto', // Let AI detect language automatically
            }),
          )
          .timeout(const Duration(
              seconds: 15)); // Increased timeout for AI responses

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Log AI provider info for debugging
        if (data.containsKey('provider')) {
          print('AI Response from: ${data['provider']}');
        }

        return data['response'] ?? 'Sorry, I could not generate a response.';
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('AI request timed out - please try again');
    } catch (e) {
      throw Exception('Error getting AI response: $e');
    }
  }

  // Fallback response generator
  String getFallbackResponse(String userMessage) {
    final lowercaseText = userMessage.toLowerCase();

    if (lowercaseText.contains('disease') ||
        lowercaseText.contains('spot') ||
        lowercaseText.contains('blight')) {
      return 'I notice you\'re asking about plant diseases. While I\'m currently offline, I recommend using our disease scanner feature for accurate identification when back online.';
    } else if (lowercaseText.contains('weather') ||
        lowercaseText.contains('rain')) {
      return 'Weather information requires an internet connection. Please check your connection and try again.';
    } else if (lowercaseText.contains('soil') ||
        lowercaseText.contains('fertilizer')) {
      return 'Soil and fertilizer questions are important. When back online, I can provide detailed recommendations based on our database.';
    }

    return 'I\'m currently offline. Please check your internet connection and try again. In the meantime, you can browse previously saved responses or use our offline features.';
  }
}
