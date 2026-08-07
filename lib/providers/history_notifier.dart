/*
 * history_notifier.dart
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryNotifier extends ChangeNotifier {
  static const String _keyHistory = 'history';
  static const String _keyUrl = 'url';
  static const String _keyTimestamp = 'timestamp';
  static const String _keyLastViewedParagraphIndex =
      'last_viewed_paragraph_index';

  // For fetching data from the web
  bool _isLoading = false;
  String? _data;
  String? _error;

  String? get error => _error;

  // For storing and retrieving data from SharedPreferences
  final SharedPreferences prefs;
  List<Map<String, dynamic>> _historyList = [];
  final Map<String, (String?, List<String>, String?, int)> _cachedContents = {};
  int _currentParagraphIndex = 0;

  HistoryNotifier(this.prefs) {
    try {
      final historyJson = prefs.getString(_keyHistory);
      if (historyJson != null) {
        final decoded = jsonDecode(historyJson);
        if (decoded is List) {
          _historyList = List<Map<String, dynamic>>.from(decoded);
          if (_historyList.isNotEmpty) {
            _currentParagraphIndex =
                _historyList.first[_keyLastViewedParagraphIndex] ?? 0;
          }
        }
      } else {
        _historyList = [];
      }
    } catch (e) {
      _historyList = [];
    }
  }

  // For fetching data from the web
  bool get isLoading => _isLoading;

  String? get data => _data;

  Future<void> fetchAllLinkedContents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      for (final entry in _historyList) {
        final url = entry[_keyUrl] as String;
        _cachedContents[url] = await _fetchLinkedContent(url);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCurrentLinkedContent() async {
    if (currentParagraphList != null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final contents = await _fetchLinkedContent(currentUrl);
      _cachedContents[currentUrl] = contents;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI to stop spinner
    }
  }

  Future<(String?, List<String>, String?, int)> _fetchLinkedContent(
    String url,
  ) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final lang = document.documentElement?.attributes['lang'];
      final title = document.querySelector('title')?.text;
      final pElements = document.getElementsByTagName('p');
      return (
        title,
        pElements
            .map((element) => element.text.trim())
            .where((text) => text.isNotEmpty)
            .toList(),
        lang,
        pElements
            .map((element) => element.text.codeUnits.length)
            .reduce((a, b) => a + b),
      );
    } else {
      throw Exception('Failed to fetch a page');
    }
  }

  Map<String, (String?, List<String>, String?, int)> get cachedContents =>
      _cachedContents;

  List<Map<String, dynamic>> get historyList => _historyList;

  String get currentUrl =>
      _historyList.isEmpty ? '' : _historyList.first[_keyUrl] as String;

  String get currentTimestamp => _historyList.isEmpty
      ? ''
      : DateFormat.yMd().add_jm().format(
          DateTime.parse(_historyList.first[_keyTimestamp]),
        );

  String get currentDomainName =>
      Uri.parse(currentUrl).host.replaceFirst('www.', '');

  String get currentTitle => _cachedContents[currentUrl]?.$1 ?? currentUrl;

  String exportHistory() =>
      _historyList.map((e) => e[_keyUrl] as String).join('\n');

  bool isSelected(String url) =>
      _historyList.isNotEmpty && _historyList.first[_keyUrl] == url;

  bool contains(String entry) => _historyList.any((e) => e[_keyUrl] == entry);

  Future<void> select(String url) async {
    final index = _historyList.indexWhere((e) => e[_keyUrl] == url);
    if (index > 0) {
      _historyList.first[_keyLastViewedParagraphIndex] = _currentParagraphIndex;
      final entry = _historyList[index];
      _historyList.removeAt(index);
      entry[_keyTimestamp] = DateTime.now().toIso8601String();
      _historyList.insert(0, entry);
      _currentParagraphIndex = entry[_keyLastViewedParagraphIndex] ?? 0;
      notifyListeners();
      await prefs.setString(_keyHistory, jsonEncode(_historyList));
    } else if (index != 0) {
      add(url);
    }
  }

  Future<void> add(String url) async {
    _currentParagraphIndex = 0;
    _historyList.insert(0, {
      _keyUrl: url,
      _keyTimestamp: DateTime.now().toIso8601String(),
      _keyLastViewedParagraphIndex: _currentParagraphIndex,
    });
    _cachedContents[url] = await _fetchLinkedContent(url);
    notifyListeners();
    await prefs.setString(_keyHistory, jsonEncode(_historyList));
  }

  Future<void> removeAt(int index) async {
    if (_historyList.length > 1) {
      if (index >= 0 && index < _historyList.length) {
        _historyList.removeAt(index);
        if (index == 0) {
          if (_historyList.isEmpty) {
            _currentParagraphIndex = 0;
          } else {
            final entry = _historyList.first;
            _currentParagraphIndex = entry[_keyLastViewedParagraphIndex] ?? 0;
          }
        }
        notifyListeners();
        await prefs.setString(_keyHistory, jsonEncode(_historyList));
      }
    }
  }

  Future<void> remove(String url) async {
    final index = _historyList.indexWhere((e) => e[_keyUrl] == url);
    removeAt(index);
  }

  Future<void> clearAll() async {
    _historyList = [];
    notifyListeners();
    await prefs.setString(_keyHistory, jsonEncode(_historyList));
  }

  String? title(String url) => _cachedContents[url]?.$1;

  List<String>? get currentParagraphList => _cachedContents[currentUrl]?.$2;

  int get currentParagraphIndex => _currentParagraphIndex;

  Future<void> setCurrentParagraphIndex(int index) async {
    if (_currentParagraphIndex != index) {
      _currentParagraphIndex = index;
      _historyList.first[_keyLastViewedParagraphIndex] = _currentParagraphIndex;
      notifyListeners();
      await prefs.setString(_keyHistory, jsonEncode(_historyList));
    }
  }

  String get currentParagraph =>
      currentParagraphList?[_currentParagraphIndex] ?? '';

  String getContentSize(String url) {
    final size = _cachedContents[url]?.$4;
    return size == null
        ? '? B'
        : size < 1000
        ? '$size B'
        : '${(size / 1024).round().toString()} KB';
  }

  String? getContentLanguage(String url) {
    return _cachedContents[url]?.$3;
  }

  bool get isNotFirstParagraph => _currentParagraphIndex > 0;

  bool get isNotLastParagraph =>
      currentParagraphList != null &&
      _currentParagraphIndex != currentParagraphList!.length - 1;

  Future<void> movePreviousParagraph() async {
    if (isNotFirstParagraph) {
      _currentParagraphIndex--;
      _historyList.first[_keyLastViewedParagraphIndex] = _currentParagraphIndex;
      notifyListeners();
      prefs.setString(_keyHistory, jsonEncode(_historyList));
    }
  }

  Future<void> moveNextParagraph() async {
    if (isNotLastParagraph) {
      _currentParagraphIndex++;
      _historyList.first[_keyLastViewedParagraphIndex] = _currentParagraphIndex;
      notifyListeners();
      prefs.setString(_keyHistory, jsonEncode(_historyList));
    }
  }

  Future<void> moveToFirstParagraph() async {
    if (isNotFirstParagraph) {
      _currentParagraphIndex = 0;
      _historyList.first[_keyLastViewedParagraphIndex] = _currentParagraphIndex;
      notifyListeners();
      await prefs.setString(_keyHistory, jsonEncode(_historyList));
    }
  }

  Future<void> moveToLastParagraph() async {
    if (isNotLastParagraph) {
      _currentParagraphIndex = currentParagraphList!.length - 1;
      _historyList.first[_keyLastViewedParagraphIndex] = _currentParagraphIndex;
      notifyListeners();
      await prefs.setString(_keyHistory, jsonEncode(_historyList));
    }
  }
}
