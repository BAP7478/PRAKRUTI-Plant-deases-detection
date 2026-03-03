import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../services/api_service.dart';
import '../providers/language_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AdminApiTestScreen extends StatefulWidget {
  const AdminApiTestScreen({super.key});

  @override
  State<AdminApiTestScreen> createState() => _AdminApiTestScreenState();
}

class _AdminApiTestScreenState extends State<AdminApiTestScreen> {
  final ApiService _apiService = ApiService();
  final _locationController = TextEditingController();

  bool _isAdmin = false;
  bool _isTestingHealth = false;
  bool _isTestingPrediction = false;
  bool _isTestingRemedies = false;
  bool _isTestingWeather = false;

  String? _healthResult;
  String? _predictionResult;
  String? _remediesResult;
  String? _weatherResult;

  File? _selectedImage;
  Uint8List? _selectedImageBytes; // For web platform
  String? _selectedImageName;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isAdmin = prefs.getBool('is_admin') ?? false;

    if (!isAdmin) {
      // Not an admin, redirect back
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied. Admin privileges required.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isAdmin = isAdmin;
    });
  }

  Future<void> _testHealthEndpoint() async {
    setState(() {
      _isTestingHealth = true;
      _healthResult = null;
    });

    try {
      final isHealthy = await _apiService.checkHealth();
      setState(() {
        _healthResult = isHealthy
            ? '✅ Backend is healthy and responding'
            : '❌ Backend health check failed';
      });
    } catch (e) {
      setState(() {
        _healthResult = '❌ Health check error: $e';
      });
    } finally {
      setState(() {
        _isTestingHealth = false;
      });
    }
  }

  Future<void> _selectAndTestImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isTestingPrediction = true;
          _predictionResult = null;
          if (kIsWeb) {
            image.readAsBytes().then((bytes) {
              setState(() {
                _selectedImageBytes = bytes;
              });
            });
          } else {
            _selectedImage = File(image.path);
          }
        });

        final result = await _apiService.predictDisease(image);

        setState(() {
          _predictionResult = '''
✅ Prediction successful!
🏷️ Disease: ${result['predicted_class']}
📊 Confidence: ${(result['confidence'] * 100).toStringAsFixed(1)}%
⏱️ Processing Time: ${result['processing_time']?.toStringAsFixed(3)}s
🗂️ Cached: ${result['cached'] ?? false}
          ''';
        });
      }
    } catch (e) {
      setState(() {
        _predictionResult = '❌ Prediction error: $e';
      });
    } finally {
      setState(() {
        _isTestingPrediction = false;
      });
    }
  }

  Future<void> _testRemediesEndpoint() async {
    const testDisease = 'Rice_Blast';

    setState(() {
      _isTestingRemedies = true;
      _remediesResult = null;
    });

    try {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final currentLanguage = languageProvider.currentLanguageCode;
      final result = await _apiService.getRemedies(testDisease, language: currentLanguage);
      final remedies = result['remedies'] as List<dynamic>? ?? [];

      setState(() {
        _remediesResult = '''
✅ Remedies retrieved successfully!
🏷️ Disease: $testDisease
📝 Remedies Count: ${remedies.length}
📋 Remedies:
${remedies.map((r) => '• $r').join('\n')}
        ''';
      });
    } catch (e) {
      setState(() {
        _remediesResult = '❌ Remedies error: $e';
      });
    } finally {
      setState(() {
        _isTestingRemedies = false;
      });
    }
  }

  Future<void> _testWeatherEndpoint() async {
    final location = _locationController.text.trim();
    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location')),
      );
      return;
    }

    setState(() {
      _isTestingWeather = true;
      _weatherResult = null;
    });

    try {
      final result = await _apiService.getWeather(location);

      setState(() {
        _weatherResult = '''
✅ Weather data retrieved!
📍 Location: ${result['location']}
🌡️ Temperature: ${result['temperature']}°C
💧 Humidity: ${result['humidity']}%
☁️ Condition: ${result['description']}
💨 Wind Speed: ${result['wind_speed']} m/s
        ''';
      });
    } catch (e) {
      setState(() {
        _weatherResult = '❌ Weather error: $e';
      });
    } finally {
      setState(() {
        _isTestingWeather = false;
      });
    }
  }

  Widget _buildTestCard({
    required String title,
    required String description,
    required VoidCallback onTest,
    required bool isLoading,
    String? result,
    Widget? extraContent,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : onTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Test'),
                ),
              ],
            ),
            if (extraContent != null) ...[
              const SizedBox(height: 12),
              extraContent,
            ],
            if (result != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: result.startsWith('✅')
                      ? Colors.green[50]
                      : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: result.startsWith('✅')
                        ? Colors.green[200]!
                        : Colors.red[200]!,
                  ),
                ),
                child: Text(
                  result,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: result.startsWith('✅')
                        ? Colors.green[800]
                        : Colors.red[800],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test Console'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green,
              Colors.green[50]!,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin API Testing Console',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Test all backend API endpoints and functionality',
                              style: TextStyle(
                                color: Colors.red[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Health Check Test
                _buildTestCard(
                  title: 'Health Check',
                  description:
                      'Test if the backend server is running and responding',
                  onTest: _testHealthEndpoint,
                  isLoading: _isTestingHealth,
                  result: _healthResult,
                ),

                // Disease Prediction Test
                _buildTestCard(
                  title: 'Disease Prediction',
                  description: 'Test image upload and disease prediction',
                  onTest: _selectAndTestImage,
                  isLoading: _isTestingPrediction,
                  result: _predictionResult,
                  extraContent: (_selectedImage != null || _selectedImageBytes != null)
                      ? Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: kIsWeb && _selectedImageBytes != null
                                  ? MemoryImage(_selectedImageBytes!) as ImageProvider
                                  : FileImage(_selectedImage!) as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : null,
                ),

                // Remedies Test
                _buildTestCard(
                  title: 'Disease Remedies',
                  description: 'Test remedies retrieval for Rice_Blast',
                  onTest: _testRemediesEndpoint,
                  isLoading: _isTestingRemedies,
                  result: _remediesResult,
                ),

                // Weather Test
                _buildTestCard(
                  title: 'Weather Data',
                  description: 'Test weather information retrieval',
                  onTest: _testWeatherEndpoint,
                  isLoading: _isTestingWeather,
                  result: _weatherResult,
                  extraContent: TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Enter location (e.g., Mumbai, Delhi)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
