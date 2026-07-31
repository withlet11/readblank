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
  // For fetching data from the web
  bool _isLoading = false;
  String? _data;
  String? _error;

  // For storing and retrieving data from SharedPreferences
  final SharedPreferences prefs;
  List<Map<String, dynamic>> _historyList = [];
  final Map<String, (String?, List<String>)> _cachedContents = {};
  int _currentParagraphIndex = 0;

  HistoryNotifier(this.prefs) {
    try {
      final historyJson = prefs.getString('history');
      if (historyJson != null) {
        final decoded = jsonDecode(historyJson);
        if (decoded is List) {
          _historyList = List<Map<String, dynamic>>.from(decoded);
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

  Future<void> fetchAllUrls() async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Notify UI to show spinner

    try {
      for (final entry in _historyList) {
        final url = entry['url'] as String;
        _cachedContents[url] = await _fetchData(url);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI to stop spinner
    }
  }

  Future<void> fetchCurrentUrl() async {
    if (currentParagraphList != null) return;

    _isLoading = true;
    _error = null;
    notifyListeners(); // Notify UI to show spinner

    try {
      final contents = await _fetchData(currentUrl);
      _cachedContents[currentUrl] = contents;
    } catch (e) {
      print('fetchCurrentUrl() error: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI to stop spinner
    }
  }

  Future<(String?, List<String>)> _fetchData(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final title = document.querySelector('title')?.text;
      final pElements = document.getElementsByTagName('p');
      return (
        title,
        pElements
            .map((element) => element.text.trim())
            .where((text) => text.isNotEmpty)
            .toList(),
      );
    } else {
      throw Exception('Failed to load page');
    }
  }

  Map<String, (String?, List<String>)> get cachedContents => _cachedContents;

  List<Map<String, dynamic>> get historyList => _historyList;

  String get currentUrl =>
      _historyList.isEmpty ? '' : _historyList.first['url'] as String;

  String get currentTimestamp => _historyList.isEmpty
      ? ''
      : DateFormat.yMd().add_jm().format(
          DateTime.parse(_historyList.first['timestamp']),
        );

  String get currentDomainName =>
      Uri.parse(currentUrl).host.replaceFirst('www.', '');

  String get currentTitle => _cachedContents[currentUrl]?.$1 ?? currentUrl;

  String exportHistory() =>
      _historyList.map((e) => e['url'] as String).join('\n');

  bool isSelected(String url) =>
      _historyList.isNotEmpty && _historyList.first['url'] == url;

  bool contains(String entry) => _historyList.any((e) => e['url'] == entry);

  void select(String url) {
    final index = _historyList.indexWhere((e) => e['url'] == url);
    if (index > 0) {
      final item = _historyList[index];
      _historyList.removeAt(index);
      item['timestamp'] = DateTime.now().toIso8601String();
      _historyList.insert(0, item);
      _currentParagraphIndex = 0; // _currentIndex = 0;
      prefs.setString('history', jsonEncode(_historyList));
      notifyListeners();
    } else if (index != 0) {
      add(url);
    }
  }

  void add(String url) async {
    _historyList.insert(0, {
      'url': url,
      'timestamp': DateTime.now().toIso8601String(),
    });
    _currentParagraphIndex = 0;
    prefs.setString('history', jsonEncode(_historyList));
    _cachedContents[url] = await _fetchData(url);
    notifyListeners();
  }

  void removeAt(int index) async {
    if (_historyList.length > 1) {
      if (index >= 0 && index < _historyList.length) {
        _historyList.removeAt(index);
        if (index == 0) _currentParagraphIndex = 0;
        prefs.setString('history', jsonEncode(_historyList));
        notifyListeners();
      }
    }
  }

  void remove(String url) async {
    final index = _historyList.indexWhere((e) => e['url'] == url);
    removeAt(index);
  }

  void clearAll() async {
    _historyList = [];
    prefs.setString('history', jsonEncode(_historyList));
    notifyListeners();
  }

  String title(String url) => _cachedContents[url]?.$1 ?? 'no title';

  List<String>? get currentParagraphList => _cachedContents[currentUrl]?.$2;

  int get currentParagraphIndex => _currentParagraphIndex;

  set currentParagraphIndex(int index) {
    if (_currentParagraphIndex != index) {
      _currentParagraphIndex = index;
      notifyListeners();
    }
  }

  String get currentParagraph =>
      currentParagraphList?[_currentParagraphIndex] ?? '';

  bool get isNotFirstParagraph => _currentParagraphIndex > 0;

  bool get isNotLastParagraph =>
      currentParagraphList != null &&
      _currentParagraphIndex != currentParagraphList!.length - 1;

  void movePreviousParagraph() {
    if (isNotFirstParagraph) {
      _currentParagraphIndex--;
      notifyListeners();
    }
  }

  void moveNextParagraph() {
    if (isNotLastParagraph) {
      _currentParagraphIndex++;
      notifyListeners();
    }
  }

  void moveToFirstParagraph() {
    if (isNotFirstParagraph) {
      _currentParagraphIndex = 0;
      notifyListeners();
    }
  }

  void moveToLastParagraph() {
    if (isNotLastParagraph) {
      _currentParagraphIndex = currentParagraphList!.length - 1;
      notifyListeners();
    }
  }
}
