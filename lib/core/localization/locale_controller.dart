import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';

class LocaleController extends StateNotifier<Locale?> {
  static const String _storageKey = 'app_selected_locale';

  LocaleController() : super(null) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_storageKey);
      if (code == 'en') {
        state = const Locale('en');
      } else if (code == 'es') {
        state = const Locale('es');
      } else {
        state = null; // System default
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.setString(_storageKey, 'system');
      } else {
        await prefs.setString(_storageKey, locale.languageCode);
      }
    } catch (_) {}
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale?>((ref) {
  return LocaleController();
});

/// Returns the effective AppStrings instance for the current locale setting.
final appStringsProvider = Provider<AppStrings>((ref) {
  final selectedLocale = ref.watch(localeControllerProvider);
  if (selectedLocale != null) {
    return AppStrings.forLocale(selectedLocale);
  }
  // When system default is selected, inspect platform dispatcher locale
  final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
  return AppStrings.forLocale(systemLocale);
});
