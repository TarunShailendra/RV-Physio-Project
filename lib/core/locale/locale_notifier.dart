import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app's language, chosen by the patient and remembered between launches.
///
/// The app shipped a complete Kannada translation with no way to select it:
/// MaterialApp set no locale, so Kannada appeared only if the whole device was
/// set to it.
class LocaleNotifier extends ChangeNotifier {
  static const String _storageKey = 'app_locale';

  /// Null means follow the device.
  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_storageKey);
      if (code != null && code.isNotEmpty) _locale = Locale(code);
    } catch (e) {
      debugPrint('locale load failed: $e');
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale? value) async {
    if (_locale?.languageCode == value?.languageCode) return;
    _locale = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value == null) {
        await prefs.remove(_storageKey);
      } else {
        await prefs.setString(_storageKey, value.languageCode);
      }
    } catch (e) {
      debugPrint('locale save failed: $e');
    }
  }
}
