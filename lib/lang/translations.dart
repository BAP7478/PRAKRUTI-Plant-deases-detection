import 'package:flutter/material.dart';

class AppLocalizations {
  static String getLocalizedText(BuildContext context, {
    required String en,
    required String hi,
    required String gu,
  }) {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == 'hi' ? hi : lang == 'gu' ? gu : en;
  }

  static final Map<String, Map<String, String>> translations = {
    // Login Screen
    'login': {
      'en': 'Login',
      'hi': 'लॉग इन करें',
      'gu': 'લોગિન કરો'
    },
    'signup': {
      'en': 'Sign Up',
      'hi': 'साइन अप करें',
      'gu': 'સાઇન અપ કરો'
    },
    'welcome': {
      'en': 'Welcome to PRAKRUTI',
      'hi': 'प्रकृति में आपका स्वागत है',
      'gu': 'પ્રકૃતિમાં આપનું સ્વાગત છે'
    },
    
    // Home Screen
    'app_title': {
      'en': 'PRAKRUTI - Farm Assistant',
      'hi': 'प्रकृति - कृषि सहायक',
      'gu': 'પ્રકૃતિ - કૃષિ સહાયક'
    },
    'welcome_farmer': {
      'en': 'Welcome, Farmer!',
      'hi': 'स्वागतम् किसान भाई!',
      'gu': 'સ્વાગત છે, ખેડૂત ભાઈ!'
    },
    'ai_tech': {
      'en': 'AI Technology for Better Crop Care',
      'hi': 'आपकी फसल की देखभाल के लिए AI तकनीक',
      'gu': 'તમારા પાક માટે AI ટેકનોલોજી'
    },
    'services': {
      'en': 'Services',
      'hi': 'सेवाएं',
      'gu': 'સેવાઓ'
    },
    
    // Weather Section
    'todays_weather': {
      'en': "Today's Weather",
      'hi': 'आज का मौसम',
      'gu': 'આજનું હવામાન'
    },
    'temperature': {
      'en': 'Temperature',
      'hi': 'तापमान',
      'gu': 'તાપમાન'
    },
    'humidity': {
      'en': 'Humidity',
      'hi': 'नमी',
      'gu': 'ભેજ'
    },
    'wind_speed': {
      'en': 'Wind Speed',
      'hi': 'हवा की गति',
      'gu': 'પવનની ગતિ'
    },
    
    // Feature Cards
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
    'check_soil': {
      'en': 'Check Soil Quality',
      'hi': 'मिट्टी की गुणवत्ता',
      'gu': 'જમીનની ગુણવત્તા'
    },
    'community': {
      'en': 'Community',
      'hi': 'समुदाय',
      'gu': 'સમુદાય'
    },
    'farmer_friends': {
      'en': 'Farmer Friends',
      'hi': 'किसान मित्र',
      'gu': 'ખેડૂત મિત્રો'
    },
    'ai_assistant': {
      'en': 'AI Assistant',
      'hi': 'AI सहायक',
      'gu': 'AI સહાયક'
    },
    'ask_questions': {
      'en': 'Ask Questions',
      'hi': 'सवाल पूछें',
      'gu': 'પ્રશ્નો પૂછો'
    },
    'shop_locator': {
      'en': 'Shop Locator',
      'hi': 'दुकान खोजें',
      'gu': 'દુકાન શોધો'
    },
    'nearby_shops': {
      'en': 'Nearby Shops',
      'hi': 'नजदीकी दुकान',
      'gu': 'નજીકની દુકાનો'
    },
    'weather': {
      'en': 'Weather',
      'hi': 'मौसम',
      'gu': 'હવામાન'
    },
    'detailed_forecast': {
      'en': 'Detailed Forecast',
      'hi': 'विस्तृत जानकारी',
      'gu': 'વિસ્તૃત માહિતી'
    },

    // Navigation Bar
    'home': {
      'en': 'Home',
      'hi': 'होम',
      'gu': 'હોમ'
    },
    'scanner': {
      'en': 'Scanner',
      'hi': 'स्कैनर',
      'gu': 'સ્કેનર'
    },
    'profile': {
      'en': 'Profile',
      'hi': 'प्रोफाइल',
      'gu': 'પ્રોફાઇલ'
    },

    // Disease Scanner Screen
    'plant_disease_scanner': {
      'en': 'Plant Disease Scanner',
      'hi': 'पौधा रोग स्कैनर',
      'gu': 'છોડ રોગ સ્કેનર'
    },
    'how_to_use': {
      'en': 'How to Use:',
      'hi': 'उपयोग कैसे करें:',
      'gu': 'ઉપયોગ કેવી રીતે કરવો:'
    },
    'scanner_instructions': {
      'en': '1. Take a clear photo of the affected leaf\n2. Ensure good lighting\n3. Focus on diseased areas\n4. Tap "Analyze" for instant results',
      'hi': '1. प्रभावित पत्ती की स्पष्ट फोटो लें\n2. अच्छी रोशनी सुनिश्चित करें\n3. रोगग्रस्त क्षेत्रों पर ध्यान दें\n4. तुरंत परिणाम के लिए "विश्लेषण" टैप करें',
      'gu': '1. અસરગ્રસ્ત પાંદડાનો સ્પષ્ટ ફોટો લો\n2. સારી લાઈટિંગ સુનિશ્ચિત કરો\n3. રોગગ્રસ્ત વિસ્તારો પર ધ્યાન કેન્દ્રિત કરો\n4. તાત્કાલિક પરિણામો માટે "એનાલાઇઝ" ટેપ કરો'
    },
    'camera': {
      'en': 'Camera',
      'hi': 'कैमरा',
      'gu': 'કેમેરા'
    },
    'gallery': {
      'en': 'Gallery',
      'hi': 'गैलरी',
      'gu': 'ગેલેરી'
    },
    'analyze': {
      'en': 'Analyze Plant',
      'hi': 'पौधे का विश्लेषण करें',
      'gu': 'છોડનું વિશ્લેષણ કરો'
    },
    'analyzing': {
      'en': 'Analyzing...',
      'hi': 'विश्लेषण हो रहा है...',
      'gu': 'વિશ્લેષણ થઈ રહ્યું છે...'
    },
    'no_image': {
      'en': 'No image selected',
      'hi': 'कोई छवि चयनित नहीं',
      'gu': 'કોઈ છબી પસંદ કરેલ નથી'
    },

    // Disease Results
    'plant_healthy': {
      'en': 'Plant is Healthy!',
      'hi': 'पौधा स्वस्थ है!',
      'gu': 'છોડ તંદુરસ્ત છે!'
    },
    'disease_detected': {
      'en': 'Disease Detected',
      'hi': 'रोग का पता चला',
      'gu': 'રોગ શોધાયો'
    },
    'confidence': {
      'en': 'Confidence',
      'hi': 'विश्वास स्तर',
      'gu': 'વિશ્વસનીયતા'
    },
    'treatment_steps': {
      'en': 'Treatment Steps:',
      'hi': 'उपचार के चरण:',
      'gu': 'સારવારના પગલાં:'
    },
    'disease_info': {
      'en': 'Disease Information',
      'hi': 'रोग की जानकारी',
      'gu': 'રોગની માહિતી'
    },
    'severity': {
      'en': 'Severity',
      'hi': 'गंभीरता',
      'gu': 'ગંભીરતા'
    },
    'treatment_cost': {
      'en': 'Treatment Cost',
      'hi': 'उपचार की लागत',
      'gu': 'સારવારનો ખર્ચ'
    },
    'potential_loss': {
      'en': 'Potential Loss',
      'hi': 'संभावित नुकसान',
      'gu': 'સંભવિત નુકસાન'
    },
    'organic_treatment': {
      'en': 'Organic Treatment',
      'hi': 'जैविक उपचार',
      'gu': 'જૈવિક ઉપચાર'
    },
    'prevention': {
      'en': 'Prevention',
      'hi': 'रोकथाम',
      'gu': 'નિવારણ'
    },

    // Severity Levels
    'high': {
      'en': 'High',
      'hi': 'उच्च',
      'gu': 'ઉચ્ચ'
    },
    'medium': {
      'en': 'Medium',
      'hi': 'मध्यम',
      'gu': 'મધ્યમ'
    },
    'low': {
      'en': 'Low',
      'hi': 'कम',
      'gu': 'નીચું'
    },

    // Disease Names in Gujarati
    'disease_tomato_late_blight': {
      'en': 'Tomato Late Blight',
      'hi': 'टमाटर में देर से झुलसा',
      'gu': 'ટામેટામાં મોડો ચાંદો'
    },
    'disease_tomato_bacterial_spot': {
      'en': 'Tomato Bacterial Spot',
      'hi': 'टमाटर में बैक्टीरियल स्पॉट',
      'gu': 'ટામેટામાં બેક્ટેરિયલ ડાઘા'
    },
    'disease_potato_early_blight': {
      'en': 'Potato Early Blight',
      'hi': 'आलू में अगेती झुलसा',
      'gu': 'બટાટામાં વહેલો ચાંદો'
    },
    'disease_corn_gray_leaf_spot': {
      'en': 'Corn Gray Leaf Spot',
      'hi': 'मक्का में धूसर पत्ती धब्बा',
      'gu': 'મકાઈમાં ભૂખરા પાંદડાના ડાઘા'
    }
  };

  static String getText(BuildContext context, String key) {
    final lang = Localizations.localeOf(context).languageCode;
    return translations[key]?[lang] ?? translations[key]?['en'] ?? key;
  }
}
