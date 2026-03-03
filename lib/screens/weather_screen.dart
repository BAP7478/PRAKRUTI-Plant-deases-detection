import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../localization.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _locationController = TextEditingController();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String _error = '';
  String _defaultLocation = 'Ahmedabad';

  @override
  void initState() {
    super.initState();
    _locationController.text = _defaultLocation;
    _loadWeatherData(_defaultLocation);
  }

  Future<void> _loadWeatherData(String location) async {
    if (location.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final weather = await _apiService.getWeather(location.trim());
      setState(() {
        _weatherData = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            localization?.translate('weather_forecast') ?? 'Weather Forecast'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Location input
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: localization?.translate('location') ?? 'Location',
                hintText: localization?.translate('enter_location') ??
                    'Enter city name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _loadWeatherData(_locationController.text);
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                _loadWeatherData(value);
              },
            ),
            const SizedBox(height: 20),

            // Weather content
            Expanded(
              child: _buildWeatherContent(localization),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent(AppLocalizations? localization) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Loading weather data...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _loadWeatherData(_locationController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(
                localization?.translate('retry') ?? 'Retry',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_weatherData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wb_cloudy, size: 100, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No weather data available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final data = _weatherData!['data'] as Map<String, dynamic>;
    final status = _weatherData!['status'] as String;
    final source = _weatherData!['source'] as String;
    final location = _weatherData!['location'] as String;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Location and status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: status == 'success'
                              ? Colors.green
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          source == 'OpenWeatherMap API' ? 'Live' : 'Offline',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_weatherData!['note'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _weatherData!['note'],
                        style: TextStyle(color: Colors.orange[700]),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Main weather info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.thermostat,
                              size: 40, color: Colors.orange),
                          const SizedBox(height: 8),
                          Text(
                            data['temperature']?.toString() ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            localization?.translate('temperature') ??
                                'Temperature',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.water_drop,
                              size: 40, color: Colors.blue),
                          const SizedBox(height: 8),
                          Text(
                            '${data['humidity'] ?? 'N/A'}%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            localization?.translate('humidity') ?? 'Humidity',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    data['description'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Additional weather details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization?.translate('weather_details') ??
                        'Weather Details',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.air,
                    localization?.translate('wind_speed') ?? 'Wind Speed',
                    data['wind_speed']?.toString() ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.speed,
                    localization?.translate('pressure') ?? 'Pressure',
                    '${data['pressure'] ?? 'N/A'} hPa',
                  ),
                  if (data['uv_index'] != null)
                    _buildDetailRow(
                      Icons.wb_sunny,
                      localization?.translate('uv_index') ?? 'UV Index',
                      '${data['uv_index']}',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}
