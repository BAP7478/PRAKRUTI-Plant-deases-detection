import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/detection_history_card.dart';
import '../services/detection_history_service.dart';
import '../models/detection.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Detection>> _detectionsFuture;
  String selectedLanguage = 'English'; // Default to English

  @override
  void initState() {
    super.initState();
    _loadDetections();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    });
  }

  void _loadDetections() {
    _detectionsFuture = DetectionHistoryService.getDetections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedLanguage == 'Hindi'
            ? 'रोग पहचान इतिहास'
            : selectedLanguage == 'Gujarati'
                ? 'રોગ નિદાન ઇતિહાસ'
                : 'Detection History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filtering
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtering coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text(
                      'Are you sure you want to clear all detection history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await DetectionHistoryService.clearHistory();
                setState(() {
                  _loadDetections();
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('History cleared')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Detection>>(
        future: _detectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error loading history'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _loadDetections()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final detections = snapshot.data ?? [];

          if (detections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No detections yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use the disease scanner to analyze plants',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/scanner'),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Go to Scanner'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: detections.length,
            itemBuilder: (context, index) {
              final detection = detections[index];
              return Dismissible(
                key: ValueKey('${detection.dateTime}-${detection.imagePath}'),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) async {
                  await DetectionHistoryService.removeDetection(detection);
                  setState(() => _loadDetections());

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Detection removed')),
                    );
                  }
                },
                child: DetectionHistoryCard(
                  disease: detection.disease,
                  confidence: detection.confidence,
                  dateTime: detection.dateTime,
                  imagePath: detection.imagePath,
                  onTap: () {
                    // TODO: Navigate to detection details
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Details coming soon!')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
