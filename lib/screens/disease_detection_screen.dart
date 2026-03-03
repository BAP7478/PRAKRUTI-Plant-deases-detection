import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/disease_detection_service.dart';
import '../services/detection_history_service.dart';
import '../models/detection.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  XFile? _image;
  Uint8List? _imageBytes;
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _error;
  bool _hasCamera = false;

  @override
  void initState() {
    super.initState();
    _checkCameraAvailability();
  }

  Future<void> _checkCameraAvailability() async {
    if (kIsWeb) {
      setState(() {
        _hasCamera = false;
      });
      return;
    }
    try {
      final cameras = await availableCameras();
      setState(() {
        _hasCamera = cameras.isNotEmpty;
      });
    } catch (e) {
      print('Error checking for cameras: $e');
      setState(() {
        _hasCamera = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();

      setState(() {
        _image = pickedFile;
        _imageBytes = bytes;
        _result = null;
        _error = null;
        _isLoading = true; // Start loading right after picking
      });

      // Automatically analyze after picking
      await _analyzeImage();
    } catch (e) {
      setState(() {
        _error = 'Error picking image: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Get disease prediction
      final result = await DiseaseDetectionService.detectDisease(_image!);
      print('Received prediction result: $result');

      // If we have a disease prediction, get the remedies
      if (result['predicted_class'] != null) {
        print('Getting remedies for: ${result['predicted_class']}');
        final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
        final currentLanguage = languageProvider.currentLanguageCode;
        print('Using language: $currentLanguage');
        final remedies = await DiseaseDetectionService.getRemedies(
            result['predicted_class'], language: currentLanguage);
        result['remedies'] = remedies;
        print('Received remedies: $remedies');
      }

      // Save to history
      if (result['predicted_class'] != null && _image != null) {
        final detection = Detection(
          disease: result['predicted_class'],
          confidence: result['confidence'] as double,
          dateTime: DateTime.now(),
          imagePath: _image!.path, // Note: path might not be reliable on web for long-term storage
        );
        await DetectionHistoryService.addDetection(detection);
      }

      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error during analysis: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _error =
            'Error analyzing image: $e\nPlease try again or contact support if the issue persists.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isGujarati = languageProvider.isGujarati;

        return Scaffold(
          appBar: AppBar(
            title:
                Text(isGujarati ? 'પાક રોગ સ્કેનર' : 'Plant Disease Scanner'),
            backgroundColor: Colors.green,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: isGujarati ? 'ઇતિહાસ જુઓ' : 'View History',
                onPressed: () => Navigator.pushNamed(context, '/history'),
              ),
            ],
          ),
          body: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: ListView(
              children: [
                _buildHowToUseCard(isGujarati),
                const SizedBox(height: 20),
                _buildImagePickerBox(),
                const SizedBox(height: 20),
                if (_isLoading)
                  _buildLoadingIndicator(isGujarati)
                else if (_error != null)
                  _buildErrorWidget()
                else if (_result != null)
                  _buildResultCard(isGujarati),
                const SizedBox(height: 30),
                _buildButtons(isGujarati),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHowToUseCard(bool isGujarati) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isGujarati ? "કેવી રીતે વાપરવું:" : "How to Use:",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(isGujarati
                      ? "1. અસરગ્રસ્ત પાનનો સ્પષ્ટ ફોટો લો"
                      : "1. Take a clear photo of the affected leaf"),
                  Text(isGujarati
                      ? "2. સારી લાઇટિંગ સુનિશ્ચિત કરો"
                      : "2. Ensure good lighting"),
                  Text(isGujarati
                      ? "3. રોગગ્રસ્ત વિસ્તારો પર ધ્યાન કેન્દ્રિત કરો"
                      : "3. Focus on diseased areas"),
                  Text(isGujarati
                      ? "4. પરિણામ આપોઆપ બતાવવામાં આવશે"
                      : "4. The result will be shown automatically"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerBox() {
    return GestureDetector(
      onTap: () => _pickImage(ImageSource.gallery),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: _imageBytes == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        size: 60, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      "No image selected",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(_imageBytes!, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _buildButtons(bool isGujarati) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_hasCamera)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: Text(isGujarati ? "કેમેરા" : "Camera"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (_hasCamera) const SizedBox(width: 20),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: Text(isGujarati ? "ગેલેરી" : "Gallery"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(bool isGujarati) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(isGujarati ? "વિશ્લેષણ કરી રહ્યા છીએ..." : "Analyzing..."),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildResultCard(bool isGujarati) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isGujarati ? 'વિશ્લેષણ પરિણામ' : 'Analysis Result',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const Divider(height: 20),
            _buildResultRow(isGujarati ? 'રોગ:' : 'Disease:',
                _result!['predicted_class'] ?? 'Unknown'),
            const SizedBox(height: 8),
            _buildResultRow(isGujarati ? 'વિશ્વાસ:' : 'Confidence:',
                '${(_result!['confidence'] * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 16),
            Text(
              isGujarati ? 'ભલામણ કરેલ ક્રિયાઓ:' : 'Recommended Actions:',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_result!['remedies'] != null &&
                (_result!['remedies'] as List).isNotEmpty)
              ...(_result!['remedies'] as List).map((remedy) => ListTile(
                    leading: const Icon(Icons.check_circle_outline,
                        color: Colors.green),
                    title: Text(remedy.toString()),
                  ))
            else
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.grey),
                title: Text(isGujarati
                    ? 'કોઈ વિશિષ્ટ ઉપાય ઉપલબ્ધ નથી.'
                    : 'No specific remedies available.'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}
