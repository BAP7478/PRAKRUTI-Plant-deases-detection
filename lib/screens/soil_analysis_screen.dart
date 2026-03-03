import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'dart:math' as math;

class SoilAnalysisScreen extends StatefulWidget {
  const SoilAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<SoilAnalysisScreen> createState() => _SoilAnalysisScreenState();
}

class _SoilAnalysisScreenState extends State<SoilAnalysisScreen> {
  bool _isAnalyzing = false;
  bool _hasResults = false;
  final Map<String, double> _soilData = {};

  void _analyzeSoil() async {
    setState(() {
      _isAnalyzing = true;
      _hasResults = false;
    });

    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock soil analysis data
    setState(() {
      _soilData['pH'] = 6.5 + math.Random().nextDouble();
      _soilData['nitrogen'] = 20 + math.Random().nextDouble() * 30;
      _soilData['phosphorus'] = 15 + math.Random().nextDouble() * 25;
      _soilData['potassium'] = 150 + math.Random().nextDouble() * 100;
      _soilData['organic_matter'] = 2 + math.Random().nextDouble() * 3;
      _soilData['moisture'] = 30 + math.Random().nextDouble() * 20;
      _isAnalyzing = false;
      _hasResults = true;
    });
  }

  String _getRecommendation() {
    if (_soilData['pH']! < 6.5) {
      return 'Soil is acidic. Consider adding lime to raise pH.';
    } else if (_soilData['pH']! > 7.5) {
      return 'Soil is alkaline. Consider adding sulfur to lower pH.';
    }
    return 'Soil pH is optimal for most crops.';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isGujarati = languageProvider.isGujarati;

        return Scaffold(
          appBar: AppBar(
            title: Text(isGujarati ? 'માટીનું વિશ્લેષણ' : 'Soil Analysis'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.grass_rounded,
                        size: 64,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isGujarati
                            ? 'માટીના આરોગ્યનું વિશ્લેષણ'
                            : 'Soil Health Analysis',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.95),
                          fontFamily: isGujarati ? 'NotoSansGujarati' : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isGujarati
                            ? 'તમારી માટીની રચના વિશે વિગતવાર માહિતી મેળવો'
                            : 'Get detailed insights about your soil composition',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontFamily: isGujarati ? 'NotoSansGujarati' : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_isAnalyzing && !_hasResults) ...[
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  'How to collect soil sample:',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                _buildInstructionStep(
                                  context,
                                  '1',
                                  'Dig 6 inches deep in multiple locations',
                                  Icons.vertical_align_bottom_rounded,
                                ),
                                _buildInstructionStep(
                                  context,
                                  '2',
                                  'Mix samples thoroughly',
                                  Icons.sync_rounded,
                                ),
                                _buildInstructionStep(
                                  context,
                                  '3',
                                  'Remove debris and stones',
                                  Icons.filter_alt_rounded,
                                ),
                                _buildInstructionStep(
                                  context,
                                  '4',
                                  'Place sample in analysis chamber',
                                  Icons.science_rounded,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _analyzeSoil,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(isGujarati
                              ? 'વિશ્લેષણ શરૂ કરો'
                              : 'Start Analysis'),
                        ),
                      ],
                      if (_isAnalyzing)
                        Column(
                          children: [
                            const SizedBox(height: 32),
                            const CircularProgressIndicator(),
                            const SizedBox(height: 24),
                            Text(
                              'Analyzing soil composition...',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      if (_hasResults) ...[
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Analysis Results',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 20),
                                _buildResultItem(
                                    context,
                                    'pH Level',
                                    _soilData['pH']!.toStringAsFixed(1),
                                    '6.0-7.5'),
                                _buildResultItem(
                                    context,
                                    'Nitrogen (N)',
                                    '${_soilData['nitrogen']!.toStringAsFixed(1)} mg/kg',
                                    '20-50 mg/kg'),
                                _buildResultItem(
                                    context,
                                    'Phosphorus (P)',
                                    '${_soilData['phosphorus']!.toStringAsFixed(1)} mg/kg',
                                    '15-40 mg/kg'),
                                _buildResultItem(
                                    context,
                                    'Potassium (K)',
                                    '${_soilData['potassium']!.toStringAsFixed(1)} mg/kg',
                                    '150-250 mg/kg'),
                                _buildResultItem(
                                    context,
                                    'Organic Matter',
                                    '${_soilData['organic_matter']!.toStringAsFixed(1)}%',
                                    '2-5%'),
                                _buildResultItem(
                                    context,
                                    'Moisture Content',
                                    '${_soilData['moisture']!.toStringAsFixed(1)}%',
                                    '30-50%'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recommendations',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _getRecommendation(),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton(
                          onPressed: _analyzeSoil,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('New Analysis'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionStep(
      BuildContext context, String step, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(
      BuildContext context, String label, String value, String idealRange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              idealRange,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
