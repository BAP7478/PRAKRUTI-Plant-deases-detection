class AppConfig {
  static const String baseUrl = 'http://localhost:8000'; // UPDATED PORT TO 8000
  static const String healthEndpoint = '/health';
  static const String predictEndpoint = '/predict';
  static const String chatEndpoint = '/chat';
  static const String remediesEndpoint = '/remedies';
  static const String weatherEndpoint = '/weather';

  static String get healthUrl => '$baseUrl$healthEndpoint';
  static String get predictUrl => '$baseUrl$predictEndpoint';
  static String get chatUrl => '$baseUrl$chatEndpoint';
  static String get remediesUrl => '$baseUrl$remediesEndpoint';
  static String get weatherUrl => '$baseUrl$weatherEndpoint';

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 60000;

  // File upload configuration
  static const int maxFileSize = 10485760; // 10MB in bytes

  static const String appName = 'PRAKRUTI';
  static const String version = '2.0.0';
  static const bool isDevelopment = true;
  static const bool enableLogging = true;
}
