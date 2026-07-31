/*
 * app_preferences_notifier.dart
 *
 * Copyright 2026 Yasuhiro Yamakawa <withlet11@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software
 * and associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
 * BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesNotifier extends ChangeNotifier {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguageCode = 'language_code';
  static const String _keyFontSizeIndex = 'font_size_index';

  static const _fontSizeFactorList = [0.8, 1.0, 1.2, 1.4];

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  int _fontSizeIndex = 1;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  Locale get locale => _locale;

  int get fontSizeIndex => _fontSizeIndex;

  double get fontSizeFactor => _fontSizeFactorList[_fontSizeIndex];

  List<double> get fontSizeFactorList => _fontSizeFactorList;

  AppPreferencesNotifier() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_keyThemeMode);
    if (themeIndex != null && themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    final langCode = prefs.getString(_keyLanguageCode);
    if (langCode != null && langCode.isNotEmpty) {
      _locale = Locale(langCode);
    }

    final fontSizeIndex = prefs.getInt(_keyFontSizeIndex);
    if (fontSizeIndex != null &&
        fontSizeIndex >= 0 &&
        fontSizeIndex < _fontSizeFactorList.length) {
      _fontSizeIndex = fontSizeIndex;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
  }

  void setDarkMode(bool value) {
    if (isDarkMode == value) return;
    setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguageCode, newLocale.languageCode);
  }

  Future<void> setFontSizeIndex(int index) async {
    if (_fontSizeIndex == index) return;
    _fontSizeIndex = index;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFontSizeIndex, index);
  }
}
