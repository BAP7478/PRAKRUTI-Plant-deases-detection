import 'package:flutter/material.dart';

class LanguageController extends ChangeNotifier {
  static final LanguageController _instance = LanguageController._internal();
  factory LanguageController() => _instance;
  LanguageController._internal();

  String _currentLanguage = 'en'; // Default to English

  // Add new translations for profile
  static final Map<String, Map<String, String>> _profileTranslations = {
    'name': {'en': 'Name', 'hi': 'नाम', 'gu': 'નામ'},
    'phone': {'en': 'Phone Number', 'hi': 'फ़ोन नंबर', 'gu': 'ફોન નંબર'},
    'location': {'en': 'Location', 'hi': 'स्थान', 'gu': 'સ્થળ'},
    'farm_size': {'en': 'Farm Size', 'hi': 'खेत का आकार', 'gu': 'ખેતરનું માપ'},
    'crop_types': {
      'en': 'Crop Types',
      'hi': 'फसल के प्रकार',
      'gu': 'પાકના પ્રકાર'
    },
    'profile_updated': {
      'en': 'Profile updated successfully',
      'hi': 'प्रोफ़ाइल सफलतापूर्वक अपडेट की गई',
      'gu': 'પ્રોફાઇલ સફળતાપૂર્વક અપડેટ થઈ'
    },
  };

  String get currentLanguage => _currentLanguage;

  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
    notifyListeners();
  }

  // Gujarati Translations
  static final Map<String, Map<String, String>> translations = {
    ..._profileTranslations,
    // App Title and Common Text
    'app_title': {
      'en': 'PRAKRUTI - Farm Assistant',
      'hi': 'प्रकृति - कृषि सहायक',
      'gu': 'પ્રકૃતિ - કૃષિ સહાયક'
    },
    'welcome_message': {
      'en': 'Welcome, Farmer!',
      'hi': 'स्वागतम् किसान भाई!',
      'gu': 'સ્વાગત છે, ખેડૂત ભાઈ!'
    },
    'ai_description': {
      'en': 'AI Technology for Better Crop Care',
      'hi': 'आपकी फसल की देखभाल के लिए AI तकनीक',
      'gu': 'તમારા પાક માટે AI ટેકનોલોજી'
    },

    // Navigation
    'home': {'en': 'Home', 'hi': 'होम', 'gu': 'હોમ'},
    'scanner': {'en': 'Scanner', 'hi': 'स्कैनर', 'gu': 'સ્કેનર'},
    'community': {'en': 'Community', 'hi': 'समुदाय', 'gu': 'સમુદાય'},
    'profile': {'en': 'Profile', 'hi': 'प्रोफाइल', 'gu': 'પ્રોફાઇલ'},

    // Weather Section
    'weather_title': {
      'en': "Today's Weather",
      'hi': 'आज का मौसम',
      'gu': 'આજનું હવામાન'
    },
    'temperature': {'en': 'Temperature', 'hi': 'तापमान', 'gu': 'તાપમાન'},
    'humidity': {'en': 'Humidity', 'hi': 'नमी', 'gu': 'ભેજ'},
    'wind_speed': {'en': 'Wind Speed', 'hi': 'हवा की गति', 'gu': 'પવનની ગતિ'},

    // Features
    'disease_scanner': {
      'en': 'Disease Scanner',
      'hi': 'रोग स्कैनर',
      'gu': 'રોગ સ્કેનર'
    },
    'scan_leaves': {
      'en': 'Scan Plant Leaves',
      'hi': 'पत्ती स्कैन करें',
      'gu': 'પાંદડા સ્કેન કરો'
    },
    'soil_analysis': {
      'en': 'Soil Analysis',
      'hi': 'मिट्टी जांच',
      'gu': 'જમીન તપાસ'
    },
    'soil_quality': {
      'en': 'Check Soil Quality',
      'hi': 'मिट्टी की गुणवत्ता',
      'gu': 'જમીનની ગુણવત્તા'
    },
    'farmer_community': {
      'en': 'Farmer Community',
      'hi': 'किसान समुदाय',
      'gu': 'ખેડૂત સમુદાય'
    },
    'ask_expert': {
      'en': 'Ask Expert',
      'hi': 'विशेषज्ञ से पूछें',
      'gu': 'નિષ્ણાત ને પૂછો'
    },

    // Disease Scanner
    'take_photo': {'en': 'Take Photo', 'hi': 'फोटो लें', 'gu': 'ફોટો લો'},
    'analyze': {'en': 'Analyze', 'hi': 'विश्लेषण करें', 'gu': 'વિશ્લેષણ કરો'},
    'analyzing': {
      'en': 'Analyzing...',
      'hi': 'विश्लेषण हो रहा है...',
      'gu': 'વિશ્લેષણ થઈ રહ્યું છે...'
    },

    // Results
    'disease_detected': {
      'en': 'Disease Detected',
      'hi': 'रोग का पता चला',
      'gu': 'રોગ શોધાયો'
    },
    'healthy_plant': {
      'en': 'Healthy Plant',
      'hi': 'स्वस्थ पौधा',
      'gu': 'તંદુરસ્ત છોડ'
    },
    'treatment': {'en': 'Treatment', 'hi': 'उपचार', 'gu': 'સારવાર'},
    'prevention': {'en': 'Prevention', 'hi': 'रोकथाम', 'gu': 'નિવારણ'},

    // Login/Signup
    'login': {'en': 'Login', 'hi': 'लॉग इन करें', 'gu': 'લોગિન કરો'},
    'signup': {'en': 'Sign Up', 'hi': 'साइन अप करें', 'gu': 'સાઇન અપ કરો'},
    'email': {'en': 'Email', 'hi': 'ईमेल', 'gu': 'ઈમેલ'},
    'password': {'en': 'Password', 'hi': 'पासवर्ड', 'gu': 'પાસવર્ડ'},

    // Common Disease Names
    'tomato_blight': {
      'en': 'Tomato Late Blight',
      'hi': 'टमाटर का पछेती झुलसा',
      'gu': 'ટમેટાનો મોડો ચાંદો'
    },
    'bacterial_wilt': {
      'en': 'Bacterial Wilt',
      'hi': 'जीवाणु मुरझान',
      'gu': 'બેક્ટેરિયલ કરમાઈ'
    },
    'leaf_spot': {'en': 'Leaf Spot', 'hi': 'पत्ती धब्बा', 'gu': 'પાન પર ડાઘા'},

    // Weather Conditions
    'sunny': {'en': 'Sunny', 'hi': 'धूप', 'gu': 'તડકો'},
    'cloudy': {'en': 'Cloudy', 'hi': 'बादल', 'gu': 'વાદળછાયું'},
    'rainy': {'en': 'Rainy', 'hi': 'बारिश', 'gu': 'વરસાદી'},

    // Community Section
    'create_post': {
      'en': 'Create Post',
      'hi': 'पोस्ट बनाएं',
      'gu': 'પોસ્ટ બનાવો'
    },
    'whats_on_your_mind': {
      'en': 'What\'s on your mind?',
      'hi': 'आप क्या सोच रहे हैं?',
      'gu': 'તમે શું વિચારી રહ્યા છો?'
    },
    'add_comment': {
      'en': 'Add Comment',
      'hi': 'टिप्पणी जोड़ें',
      'gu': 'ટિપ્પણી ઉમેરો'
    },
    'write_comment': {
      'en': 'Write a comment...',
      'hi': 'टिप्पणी लिखें...',
      'gu': 'ટિપ્પણી લખો...'
    },
    'post': {'en': 'Post', 'hi': 'पोस्ट करें', 'gu': 'પોસ્ટ કરો'},
    'cancel': {'en': 'Cancel', 'hi': 'रद्द करें', 'gu': 'રદ કરો'},
    'view_all': {'en': 'View all', 'hi': 'सभी देखें', 'gu': 'બધા જુઓ'},
    'comments': {'en': 'comments', 'hi': 'टिप्पणियां', 'gu': 'ટિપ્પણીઓ'},
  };

  String getText(String key) {
    return translations[key]?[_currentLanguage] ??
        translations[key]?['en'] ??
        key;
  }
}
