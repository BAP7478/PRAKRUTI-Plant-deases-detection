import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', 'US'); // Default to English
  static const String _languageKey = 'selected_language';

  Locale get locale => _locale;
  String get currentLanguageCode => _locale.languageCode;

  LanguageProvider() {
    _loadLanguage();
  }

  // Force reset to English (useful for ensuring English default)
  Future<void> resetToEnglish() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, 'en');
      _locale = const Locale('en', 'US');
      notifyListeners();
      debugPrint('Language reset to English');
    } catch (e) {
      debugPrint('Error resetting language to English: $e');
    }
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);

      // Default to English if no preference or explicit English choice
      if (languageCode == null || languageCode == 'en') {
        _locale = const Locale('en', 'US');
        await prefs.setString(_languageKey, 'en');
        debugPrint('Language set to English (default)');
      } else if (languageCode == 'gu') {
        _locale = const Locale('gu', 'IN');
        debugPrint('Language loaded as Gujarati');
      } else {
        // Fallback to English for any unknown language code
        _locale = const Locale('en', 'US');
        await prefs.setString(_languageKey, 'en');
        debugPrint('Unknown language code, defaulting to English');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language preference: $e');
      // Always fallback to English on error
      _locale = const Locale('en', 'US');
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);

      if (languageCode == 'gu') {
        _locale = const Locale('gu', 'IN');
      } else {
        _locale = const Locale('en', 'US');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
  }

  bool get isGujarati => _locale.languageCode == 'gu';
  bool get isEnglish => _locale.languageCode == 'en';

  String get currentLanguageName =>
      _locale.languageCode == 'gu' ? 'ગુજરાતી' : 'English';

  String getLocalizedText(Map<String, String> translations) {
    return translations[_locale.languageCode] ?? translations['en'] ?? '';
  }
}
