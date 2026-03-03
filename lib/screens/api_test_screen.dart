import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/language_provider.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final ApiService _apiService = ApiService();
  String _status = 'Not tested';
  String _predictionResult = '';
  String _remedyResult = '';
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  Future<void> _checkHealth() async {
    try {
      final isHealthy = await _apiService.checkHealth();
      setState(() {
        _status = isHealthy
            ? 'Backend is healthy! 🟢'
            : 'Backend is not responding 🔴';
      });
    } catch (e) {
      setState(() {
        _status = 'Error checking health: $e';
      });
    }
  }

  Future<void> _pickAndPredict() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _selectedImageBytes = bytes;
          _predictionResult = 'Analyzing image...';
        });

        final result = await _apiService.predictDisease(_selectedImage!);
        setState(() {
          _predictionResult =
              'Disease: ${result['predicted_class']}\nConfidence: ${(result['confidence'] * 100).toStringAsFixed(2)}%';
          // Get remedies for the detected disease
          _getRemedies(result['predicted_class']);
        });
      }
    } catch (e) {
      setState(() {
        _predictionResult = 'Error: $e';
      });
    }
  }

  Future<void> _getRemedies(String disease) async {
    try {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final currentLanguage = languageProvider.currentLanguageCode;
      final result = await _apiService.getRemedies(disease, language: currentLanguage);
      setState(() {
        _remedyResult = 'Remedy: ${result['remedy']}';
      });
    } catch (e) {
      setState(() {
        _remedyResult = 'Error getting remedies: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _checkHealth,
              child: const Text('Check Backend Health'),
            ),
            const SizedBox(height: 16),
            Text('Status: $_status',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _pickAndPredict,
              child: const Text('Pick Image & Predict Disease'),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null) ...[
              SizedBox(
                height: 200,
                child: kIsWeb
                    ? Image.memory(_selectedImageBytes!)
                    : Image.file(File(_selectedImage!.path)),
              ),
              const SizedBox(height: 16),
            ],
            Text(_predictionResult,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Text(_remedyResult, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
