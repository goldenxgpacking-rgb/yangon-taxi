import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale _locale = const Locale('zh', 'CN');

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  /// Get display name for current locale
  String get displayName {
    switch (_locale.languageCode) {
      case 'en':
        return 'English';
      case 'my':
        return 'မြန်မာ (Burmese)';
      default:
        return '简体中文';
    }
  }

  /// Get locale by index (0=zh, 1=en, 2=my)
  Locale getLocaleByIndex(int index) {
    switch (index) {
      case 1:
        return const Locale('en');
      case 2:
        return const Locale('my');
      default:
        return const Locale('zh', 'CN');
    }
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null) {
      _locale = _codeToLocale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, '${newLocale.languageCode}_${newLocale.countryCode ?? ""}');
  }

  Locale _codeToLocale(String code) {
    if (code.startsWith('en')) return const Locale('en');
    if (code.startsWith('my')) return const Locale('my');
    return const Locale('zh', 'CN');
  }
}
