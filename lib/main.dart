import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'loginpage.dart';
import 'localization.dart';
import 'providers/language_provider.dart';
import 'screens/community_screen.dart';
import 'screens/soil_analysis_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/api_test_screen.dart'; // Added import for API test screen
import 'screens/admin_api_test_screen.dart'; // Added import for admin API test screen
import 'screens/disease_detection_screen.dart'; // Added import for disease detection
import 'screens/sign_up_page.dart'; // Added import for signup screen
import 'screens/history_screen.dart'; // Added import for history screen
import 'screens/profile_screen.dart'; // Added import for profile screen
import 'services/api_service.dart'; // Added import for API service
import 'config/app_config.dart'; // Added import for app configuration

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize API service
    final apiService = ApiService();
    await apiService.initialize();

    // Check backend availability (optional - won't block startup)
    if (AppConfig.enableLogging) {
      print('🌱 PRAKRUTI App Starting...');
      apiService
          .waitForBackend(maxAttempts: 3, delaySeconds: 1)
          .then((available) {
        if (available) {
          print('✅ Backend is available');
        } else {
          print('⚠️  Backend not available - app will work in offline mode');
        }
      });
    }

    List<CameraDescription> cameras = [];
    try {
      cameras = await availableCameras();
      if (AppConfig.enableLogging) {
        print('📸 Found ${cameras.length} camera(s)');
      }
    } catch (e) {
      debugPrint('Warning: Camera initialization failed: $e');
      // Continue without cameras, they will be handled in the UI
    }

    runApp(PrakrutiApp(cameras: cameras));
  } catch (e) {
    debugPrint('Error initializing app: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Error initializing app:\n$error",
                textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class PrakrutiApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const PrakrutiApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PRAKRUTI',
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('gu', 'IN'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: languageProvider.locale,
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode &&
                    supportedLocale.countryCode == locale?.countryCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            theme: ThemeData(
              primarySwatch: Colors.green,
              useMaterial3: true,
              fontFamily: 'NotoSansGujarati',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2E7D32),
                secondary: const Color(0xFF66BB6A),
                tertiary: const Color(0xFFA5D6A7),
                background: const Color(0xFFF5F5F5),
              ),
              textTheme: const TextTheme(
                displayLarge: TextStyle(
                    fontFamily: 'NotoSansGujarati',
                    fontWeight: FontWeight.bold),
                displayMedium: TextStyle(
                    fontFamily: 'NotoSansGujarati',
                    fontWeight: FontWeight.bold),
                displaySmall: TextStyle(
                    fontFamily: 'NotoSansGujarati',
                    fontWeight: FontWeight.bold),
                headlineMedium: TextStyle(
                    fontFamily: 'NotoSansGujarati',
                    fontWeight: FontWeight.w600),
                headlineSmall: TextStyle(
                    fontFamily: 'NotoSansGujarati',
                    fontWeight: FontWeight.w600),
                titleLarge: TextStyle(
                    fontFamily: 'NotoSansGujarati',
                    fontWeight: FontWeight.w600),
                bodyLarge: TextStyle(fontFamily: 'NotoSansGujarati'),
                bodyMedium: TextStyle(fontFamily: 'NotoSansGujarati'),
              ).apply(
                bodyColor: const Color(0xFF2E2E2E),
                displayColor: const Color(0xFF2E2E2E),
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAliasWithSaveLayer,
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                centerTitle: true,
              ),
            ),
            home: const LoginScreen(), // Start with login screen
            routes: {
              '/app': (context) => HomeScreen(cameras: cameras),
              '/signup': (context) => const SignUpScreen(),
              '/scanner': (context) => PlantScannerScreen(cameras: cameras),
              '/community': (context) => const CommunityScreen(),
              '/soil': (context) => const SoilAnalysisScreen(),
              '/chatbot': (context) => const ChatbotScreen(),
              '/shop': (context) => const ShopScreen(),
              '/weather': (context) => const WeatherScreen(),
              '/api-test': (context) =>
                  const ApiTestScreen(), // Added API test screen
              '/admin-api-test': (context) =>
                  const AdminApiTestScreen(), // Added admin API test screen
              '/history': (context) =>
                  const HistoryScreen(), // Added history screen
              '/profile': (context) =>
                  const ProfileScreen(), // Added profile screen
            },
          );
        },
      ),
    );
  }
}

// Disease Remedies Database
class DiseaseRemedies {
  static final Map<String, Map<String, dynamic>> remedies = {
    'Tomato_Late_blight': {
      'name_hindi': 'टमाटर में देर से झुलसा',
      'symptoms': 'Dark spots on leaves with white mold underneath',
      'treatment': [
        'Apply copper-based fungicide (Copper sulphate 2g/L)',
        'Remove and destroy affected leaves immediately',
        'Improve air circulation around plants',
        'Use Bordeaux mixture spray every 10 days'
      ],
      'prevention': 'Use drip irrigation, avoid overhead watering',
      'severity': 'High',
      'estimated_loss': '40-60%',
      'organic_treatment': 'Neem oil spray + Baking soda solution',
      'cost_estimate': '₹500-800 per acre'
    },
    'Tomato_Bacterial_spot': {
      'name_hindi': 'टमाटर में बैक्टीरियल स्पॉट',
      'symptoms': 'Small dark spots with yellow halos',
      'treatment': [
        'Apply copper bactericide',
        'Remove infected plants',
        'Sanitize tools between plants',
        'Use resistant varieties'
      ],
      'prevention': 'Crop rotation, avoid working in wet conditions',
      'severity': 'Medium',
      'estimated_loss': '20-40%',
      'organic_treatment': 'Copper soap spray',
      'cost_estimate': '₹300-500 per acre'
    },
    'Potato_Early_blight': {
      'name_hindi': 'आलू में अगेती झुलसा',
      'symptoms': 'Brown spots with concentric rings on leaves',
      'treatment': [
        'Fungicide spray (Mancozeb)',
        'Ensure proper spacing',
        'Remove lower leaves',
        'Apply every 14 days'
      ],
      'prevention': 'Proper field sanitation, resistant varieties',
      'severity': 'Medium',
      'estimated_loss': '15-25%',
      'organic_treatment': 'Compost tea + Garlic extract',
      'cost_estimate': '₹400-600 per acre'
    },
    'Corn_Gray_leaf_spot': {
      'name_hindi': 'मक्का में धूसर पत्ती धब्बा',
      'symptoms': 'Gray rectangular lesions on leaves',
      'treatment': [
        'Fungicide application',
        'Crop rotation',
        'Residue management',
        'Balanced fertilization'
      ],
      'prevention': 'Avoid continuous corn planting',
      'severity': 'Medium',
      'estimated_loss': '10-30%',
      'organic_treatment': 'Trichoderma application',
      'cost_estimate': '₹350-500 per acre'
    },
    'Healthy': {
      'name_hindi': 'स्वस्थ पौधा',
      'symptoms': 'Plant appears healthy and vibrant',
      'treatment': [
        'Continue current care routine',
        'Maintain proper watering',
        'Regular monitoring',
        'Preventive measures'
      ],
      'prevention': 'Good agricultural practices',
      'severity': 'None',
      'estimated_loss': '0%',
      'organic_treatment': 'Continue organic practices',
      'cost_estimate': '₹0'
    }
  };
}

// Weather Service
class WeatherService {
  static Future<Map<String, dynamic>> getCurrentWeather(String location) async {
    // Mock weather data - replace with actual API
    return {
      'temperature': '28°C',
      'humidity': '65%',
      'rainfall': '10mm',
      'wind_speed': '12 km/h',
      'forecast': [
        {'day': 'Today', 'temp': '28°C', 'condition': 'Partly Cloudy'},
        {'day': 'Tomorrow', 'temp': '30°C', 'condition': 'Sunny'},
        {'day': 'Day 3', 'temp': '26°C', 'condition': 'Rainy'}
      ]
    };
  }
}

// ML Service for Disease Detection
class MLService {
  static Future<Map<String, dynamic>> predictDisease(String imagePath) async {
    // Simulate ML prediction - replace with actual model
    await Future.delayed(const Duration(seconds: 2));

    // Mock predictions based on image analysis
    List<String> diseases = DiseaseRemedies.remedies.keys.toList();
    String predictedDisease =
        diseases[DateTime.now().millisecond % diseases.length];

    return {
      'disease': predictedDisease,
      'confidence': 0.85 + (DateTime.now().millisecond % 15) / 100,
      'processing_time': '2.3 seconds'
    };
  }
}

// Home Screen
class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({super.key, required this.cameras});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class ServiceItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const ServiceItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> weatherData = {};
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final weather = await WeatherService.getCurrentWeather('Gujarat');
    setState(() {
      weatherData = weather;
    });
  }

  Future<void> _checkAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isAdmin = prefs.getBool('is_admin') ?? false;
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)?.translate('app_title') ?? 'PRAKRUTI'),
        backgroundColor: Colors.green,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (String language) async {
                  await languageProvider.setLanguage(language);
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'en',
                    child: Row(
                      children: [
                        const Text('English'),
                        const SizedBox(width: 8),
                        if (languageProvider.isEnglish)
                          const Icon(Icons.check,
                              color: Colors.green, size: 16),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'gu',
                    child: Row(
                      children: [
                        const Text('ગુજરાતી',
                            style: TextStyle(fontFamily: 'NotoSansGujarati')),
                        const SizedBox(width: 8),
                        if (languageProvider.isGujarati)
                          const Icon(Icons.check,
                              color: Colors.green, size: 16),
                      ],
                    ),
                  ),
                ],
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Icon(Icons.language),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadWeather();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section with Gradient Background
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)
                                          ?.translate('welcome_farmer') ??
                                      'સ્વાગત છે, ખેડૂત!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context)
                                          ?.translate('ai_technology') ??
                                      'વધુ સારી પાક સંભાળ માટે AI ટેકનોલોજી',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.eco_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Debug API Test Card (only for admin users)
              if (_isAdmin)
                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
                    title: const Text('Admin API Test'),
                    subtitle: const Text('Test backend connectivity (Admin Only)'),
                    onTap: () => Navigator.pushNamed(context, '/admin-api-test'),
                  ),
                ),
              if (_isAdmin) const SizedBox(height: 20),
              // Weather Card
              if (weatherData.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 2,
                    shadowColor: Colors.blue.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.withOpacity(0.05),
                            Colors.lightBlue.withOpacity(0.15),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.wb_sunny_rounded,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Today\'s Weather',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _WeatherItem(
                                          icon: Icons.thermostat_rounded,
                                          valueKey: 'temperature')
                                      .buildWith(weatherData),
                                  _buildDivider(),
                                  _WeatherItem(
                                          icon: Icons.water_drop_rounded,
                                          valueKey: 'humidity')
                                      .buildWith(weatherData),
                                  _buildDivider(),
                                  _WeatherItem(
                                          icon: Icons.air_rounded,
                                          valueKey: 'wind_speed')
                                      .buildWith(weatherData),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)?.translate('services') ??
                    'Services',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Feature Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final services = [
                      ServiceItem(
                        title: AppLocalizations.of(context)
                                ?.translate('disease_scanner') ??
                            'Disease Scanner',
                        subtitle: 'Scan Plant Leaves',
                        icon: Icons.camera_alt_rounded,
                        color: const Color(0xFFE57373),
                        route: '/scanner',
                      ),
                      ServiceItem(
                        title: AppLocalizations.of(context)
                                ?.translate('chatbot') ??
                            'AI Assistant',
                        subtitle: 'Chat with AI',
                        icon: Icons.smart_toy_rounded,
                        color: const Color(0xFF9C27B0),
                        route: '/chatbot',
                      ),
                      ServiceItem(
                        title: AppLocalizations.of(context)
                                ?.translate('soil_analysis') ??
                            'Soil Analysis',
                        subtitle: 'Check Soil Quality',
                        icon: Icons.eco_rounded,
                        color: const Color(0xFF8D6E63),
                        route: '/soil',
                      ),
                      ServiceItem(
                        title: AppLocalizations.of(context)
                                ?.translate('community') ??
                            'Community',
                        subtitle: 'Farmer Friends',
                        icon: Icons.group_rounded,
                        color: const Color(0xFF64B5F6),
                        route: '/community',
                      ),
                      ServiceItem(
                        title:
                            AppLocalizations.of(context)?.translate('shop') ??
                                'Shop Locator',
                        subtitle: 'Nearby Shops',
                        icon: Icons.store_rounded,
                        color: const Color(0xFF81C784),
                        route: '/shop',
                      ),
                      ServiceItem(
                        title: AppLocalizations.of(context)
                                ?.translate('weather') ??
                            'Weather',
                        subtitle: 'Detailed Forecast',
                        icon: Icons.wb_cloudy_rounded,
                        color: const Color(0xFF4FC3F7),
                        route: '/weather',
                      ),
                      ServiceItem(
                        title: AppLocalizations.of(context)
                                ?.translate('history') ??
                            'Disease History',
                        subtitle: 'Past Detections',
                        icon: Icons.history_rounded,
                        color: const Color(0xFF4DB6AC),
                        route: '/history',
                      ),
                    ];

                    final service = services[index];
                    return _buildFeatureCard(
                      service.title,
                      service.subtitle,
                      service.icon,
                      service.color,
                      service.route,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, // Home is always 0 since this is the home screen
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)?.translate('home') ?? 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera),
            label:
                AppLocalizations.of(context)?.translate('scanner') ?? 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.group),
            label: AppLocalizations.of(context)?.translate('community') ??
                'Community',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label:
                AppLocalizations.of(context)?.translate('profile') ?? 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.pushNamed(context, '/scanner');
              break;
            case 2:
              Navigator.pushNamed(context, '/community');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, String subtitle, IconData icon, Color color, String route) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.05),
                color.withOpacity(0.15),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildDivider() {
  return Container(
    height: 40,
    width: 1,
    color: Colors.grey.withOpacity(0.2),
  );
}

class _WeatherItem {
  final IconData icon;
  final String valueKey;
  const _WeatherItem({required this.icon, required this.valueKey});

  Widget buildWith(Map<String, dynamic> data) {
    final value = data[valueKey] ?? '';
    String label = valueKey
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.blue,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// Plant Scanner Screen
class PlantScannerScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const PlantScannerScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return const DiseaseDetectionScreen();
  }
}

// Removed old implementation
