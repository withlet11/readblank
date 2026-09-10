// Copyright 2026 WITHLET11 <withlet11@gmail.com>
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HiddenMode { wholeWords, beginningOfWords, endOfWords }

class AppPreferencesNotifier extends ChangeNotifier {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguageCode = 'language_code';
  static const String _keyFontSizeIndex = 'font_size_index';
  static const String _keySpeechRateIndex = 'speech_rate_index';
  static const String _keySpeechVolumeIndex = 'speech_volume_index';
  static const String _keyHiddenMode = 'hidden_mode';

  static const _fontSizeFactorList = [1.4, 1.2, 1.0, 0.8];
  static const _speechVolumeFactorList = [1.0, 0.67, 0.33, 0.0];
  static const _speechRateFactorList = [1.0, 0.75, 0.5, 0.25];

  HiddenMode _hiddenMode = HiddenMode.wholeWords;
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  int _fontSizeIndex = 2;
  int _speechVolumeIndex = 0;
  int _speechRateIndex = 2;
  int _mainPageSelectedIndex = 0;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  HiddenMode get hiddenMode => _hiddenMode;

  ThemeMode get themeMode => _themeMode;

  Locale get locale => _locale;

  int get fontSizeIndex => _fontSizeIndex;

  double get fontSizeFactor => _fontSizeFactorList[_fontSizeIndex];

  List<double> get fontSizeFactorList => _fontSizeFactorList;

  int get speechVolumeIndex => _speechVolumeIndex;

  double get speechVolumeFactor => _speechVolumeFactorList[_speechVolumeIndex];

  List<double> get speechVolumeFactorList => _speechVolumeFactorList;

  int get speechRateIndex => _speechRateIndex;

  double get speechRateFactor => _speechRateFactorList[_speechRateIndex];

  List<double> get speechRateFactorList => _speechRateFactorList;

  int get mainPageSelectedIndex => _mainPageSelectedIndex;

  void setMainPageSelectedIndex(int index) {
    if (_mainPageSelectedIndex == index) return;
    _mainPageSelectedIndex = index;
    notifyListeners();
  }

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

    final speechVolumeIndex = prefs.getInt(_keySpeechVolumeIndex);
    if (speechVolumeIndex != null &&
        speechVolumeIndex >= 0 &&
        speechVolumeIndex < _speechVolumeFactorList.length) {
      _speechVolumeIndex = speechVolumeIndex;
    }

    final speechRateIndex = prefs.getInt(_keySpeechRateIndex);
    if (speechRateIndex != null &&
        speechRateIndex >= 0 &&
        speechRateIndex < _speechRateFactorList.length) {
      _speechRateIndex = speechRateIndex;
    }

    final hiddenModeName = prefs.getString(_keyHiddenMode);
    if (hiddenModeName == null) {
      _hiddenMode = HiddenMode.wholeWords;
    } else {
      try {
        _hiddenMode = HiddenMode.values.byName(hiddenModeName);
      } catch (_) {
        _hiddenMode = HiddenMode.wholeWords;
      }
    }

    notifyListeners();
  }

  Future<void> setHiddenMode(HiddenMode mode) async {
    if (_hiddenMode == mode) return;
    _hiddenMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHiddenMode, hiddenMode.name);
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

  Future<void> setSpeechVolumeIndex(int index) async {
    if (_speechVolumeIndex == index) return;
    _speechVolumeIndex = index;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySpeechVolumeIndex, index);
  }

  Future<void> setSpeechRateIndex(int index) async {
    if (_speechRateIndex == index) return;
    _speechRateIndex = index;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySpeechRateIndex, index);
  }
}
