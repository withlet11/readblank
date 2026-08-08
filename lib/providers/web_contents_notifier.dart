/*
 * web_contents_notifier.dart
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
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheContent {
  final String? title;
  final List<String> paragraphs;
  final String? language;
  final int size;

  CacheContent({
    required this.title,
    required this.paragraphs,
    required this.language,
    required this.size,
  });
}

class WebContentsNotifier extends ChangeNotifier {
  static const String _keyHistory = 'history';
  static const String _keyFavorites = 'bookmarks';
  static const String _keyUrl = 'url';
  static const String _keyLinkId = 'link_id';
  static const String _keyTitle = 'title';
  static const String _keyTimestamp = 'timestamp';
  static const String _keyLastViewedParagraphIndex =
      'last_viewed_paragraph_index';

  // For storing and retrieving data from SharedPreferences
  final SharedPreferences sharedPrefs;

  // For fetching data from the web
  bool _isLoading = false;
  String? _data;
  String? _error;

  // For storing data
  List<Map<String, dynamic>> _historyList = [];
  List<Map<String, dynamic>> _favoriteList = [];
  final Map<String, CacheContent> _cachedContents = {};
  int _currentParagraphIndex = 0;

  WebContentsNotifier(this.sharedPrefs) {
    _retrieveHistoryFromSharedPreferences();
    _retrieveFavoritesFromSharedPreferences();
  }

  // History data handling
  void _retrieveHistoryFromSharedPreferences() {
    try {
      final historyJson = sharedPrefs.getString(_keyHistory);
      if (historyJson != null) {
        final decoded = jsonDecode(historyJson);
        if (decoded is List) {
          _historyList = List<Map<String, dynamic>>.from(decoded);
          _currentParagraphIndex =
              _selectedEntry?[_keyLastViewedParagraphIndex] ?? 0;
        }
      } else {
        _historyList = [];
      }
    } catch (e) {
      _historyList = [];
    }
  }

  Future<void> _fetchAllHistoryContents() async {
    for (final entry in _historyList) {
      final url = entry[_keyUrl] as String;
      if (!_isCached(url)) {
        await _fetchLinkedContent(url);
      }
    }
  }

  List<Map<String, dynamic>> get historyList => _historyList;

  String get historyJsonData => jsonEncode(_historyList);

  bool containsInHistory(String entry) {
    return _historyList.any((e) => e[_keyUrl] == entry);
  }

  // Modify history
  Future<void> addHistory(String url) async {
    if (!_isCached(url)) {
      await _fetchLinkedContent(url);
    }
    _currentParagraphIndex = 0;
    final now = DateTime.now();
    _historyList.insert(0, {
      _keyUrl: url,
      _keyLinkId: _intToBase64(now.microsecondsSinceEpoch),
      _keyTitle: _getCachedContent(url)?.title,
      _keyTimestamp: now.toIso8601String(),
      _keyLastViewedParagraphIndex: _currentParagraphIndex,
    });
    notifyListeners();
    await sharedPrefs.setString(_keyHistory, historyJsonData);
  }

  Future<void> removeHistoryAt(int index) async {
    if (_historyList.length > 1) {
      if (index >= 0 && index < _historyList.length) {
        _historyList.removeAt(index);
        if (index == 0) {
          _currentParagraphIndex =
              _selectedEntry?[_keyLastViewedParagraphIndex] ?? 0;
        }
        notifyListeners();
        await sharedPrefs.setString(_keyHistory, historyJsonData);
      }
    }
  }

  Future<void> removeHistory(String url) async {
    final index = _historyList.indexWhere((e) => e[_keyUrl] == url);
    removeHistoryAt(index);
  }

  Future<void> clearAllHistory() async {
    _historyList = [];
    notifyListeners();
    await sharedPrefs.setString(_keyHistory, historyJsonData);
  }

  // Select page from history
  bool isSelected(String url) =>
      _historyList.isNotEmpty && _historyList.first[_keyUrl] == url;

  Future<void> select(String url) async {
    final index = _historyList.indexWhere((e) => e[_keyUrl] == url);
    if (index > 0) {
      _historyList.first[_keyLastViewedParagraphIndex] = _currentParagraphIndex;
      final entry = _historyList[index];
      entry[_keyTimestamp] = DateTime.now().toIso8601String();
      _enrichHistoryEntry(entry, url);
      _historyList.removeAt(index);
      _historyList.insert(0, entry);
      _currentParagraphIndex = entry[_keyLastViewedParagraphIndex] ?? 0;
      notifyListeners();
      await sharedPrefs.setString(_keyHistory, historyJsonData);
    } else if (index != 0) {
      addHistory(url);
    }
  }

  Map<String, dynamic>? get _selectedEntry {
    return _historyList.isEmpty ? null : _historyList.first;
  }

  void _enrichHistoryEntry(Map<String, dynamic> entry, String url) {
    // link_id: default to base64(timestamp) if missing
    if (entry[_keyLinkId] == null) {
      entry[_keyLinkId] = _intToBase64(
        DateTime.parse(entry[_keyTimestamp]).microsecondsSinceEpoch,
      );
    }

    // title: default to cached title if missing
    if (entry[_keyTitle] == null) {
      entry[_keyTitle] = _getCachedTitle(url);
    }

    // timestamp: default to current time if missing
    if (entry[_keyTimestamp] == null) {
      entry[_keyTimestamp] = DateTime.now().toIso8601String();
    }

    // last_viewed_paragraph_index: default to 0 if missing
    if (entry[_keyLastViewedParagraphIndex] == null) {
      entry[_keyLastViewedParagraphIndex] = 0;
    }
  }

  String _intToBase64(int number) {
    final byteData = ByteData(8)..setInt64(0, number);
    final bytes = byteData.buffer.asUint8List();
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  // Favorite data handling
  void _retrieveFavoritesFromSharedPreferences() {
    try {
      final favoritesJson = sharedPrefs.getString(_keyFavorites);
      if (favoritesJson != null) {
        final decoded = jsonDecode(favoritesJson);
        if (decoded is List) {
          _favoriteList = List<Map<String, dynamic>>.from(decoded);
        }
      } else {
        _favoriteList = [];
      }
    } catch (e) {
      _favoriteList = [];
    }
  }

  Future<void> _fetchAllFavoriteContents() async {
    for (final entry in _favoriteList) {
      String url = entry[_keyUrl];
      if (!_isCached(url)) {
        await _fetchLinkedContent(url);
      }
      entry[_keyTitle] = _getCachedContent(url)?.title;
    }
  }

  List<Map<String, dynamic>> get favoriteList => _favoriteList;

  String get favoritesJsonData => jsonEncode(_favoriteList);

  bool containsInFavorites(String url) {
    return _favoriteList.any((e) => e[_keyUrl] == url);
  }

  // Modify favorites
  void addFavorite(String url, String title) async {
    if (!_isCached(url)) {
      await _fetchLinkedContent(url);
      _favoriteList.add({_keyUrl: url, _keyTitle: _getCachedTitle(url)});
    } else {
      _favoriteList.add({_keyUrl: url, _keyTitle: title});
    }
    sharedPrefs.setString(_keyFavorites, favoritesJsonData);
    notifyListeners();
  }

  Future<void> removeFavoriteAt(int index) async {
    if (_favoriteList.length > 1) {
      if (index >= 0 && index < _favoriteList.length) {
        _favoriteList.removeAt(index);
        notifyListeners();
        await sharedPrefs.setString(_keyFavorites, favoritesJsonData);
      }
    }
  }

  Future<void> removeFavorite(String url) async {
    final index = _favoriteList.indexWhere((e) => e[_keyUrl] == url);
    removeFavoriteAt(index);
  }

  void clearAllFavorite() async {
    _favoriteList = [];
    sharedPrefs.setString(_keyFavorites, favoritesJsonData);
    notifyListeners();
  }

  // Fetch and cache data from the web
  bool get isLoading => _isLoading;

  String? get data => _data;

  String? get error => _error;

  Future<void> fetchAllLinkedContents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _fetchAllHistoryContents();
      _fetchAllFavoriteContents();
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
      await _fetchLinkedContent(currentUrl);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchLinkedContent(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final lang = document.documentElement?.attributes['lang'];
      final title = document.querySelector('title')?.text;
      final pElements = document.getElementsByTagName('p');
      _cachedContents[url] = CacheContent(
        title: title,
        paragraphs: pElements
            .map((element) => element.text.trim())
            .where((text) => text.isNotEmpty)
            .toList(),
        language: lang,
        size: pElements
            .map((element) => element.text.codeUnits.length)
            .reduce((a, b) => a + b),
      );
    } else {
      throw Exception('Failed to fetch a page');
    }
  }

  bool _isCached(String url) => _cachedContents.containsKey(url);

  CacheContent? _getCachedContent(String url) => _cachedContents[url];

  List<String>? _getCachedParagraphList(String url) =>
      _cachedContents[url]?.paragraphs;

  String? _getCachedTitle(String url) => _cachedContents[url]?.title;

  String getCachedContentSize(String url) {
    final size = _cachedContents[url]?.size;
    return size == null
        ? '? B'
        : size < 1000
        ? '$size B'
        : '${(size / 1024).round().toString()} KB';
  }

  String? getCachedContentLanguage(String url) {
    return _cachedContents[url]?.language;
  }

  // Getters of current page properties
  String get currentUrl => _selectedEntry?[_keyUrl] ?? '';

  String? get currentLinkId => _selectedEntry?[_keyLinkId];

  String get currentTimestamp {
    return _selectedEntry == null
        ? ''
        : DateFormat.yMd().add_jm().format(
            DateTime.parse(_selectedEntry![_keyTimestamp]),
          );
  }

  String get currentDomainName =>
      Uri.parse(currentUrl).host.replaceFirst('www.', '');

  String? get currentTitle => _selectedEntry?[_keyTitle];

  List<String>? get currentParagraphList => _getCachedParagraphList(currentUrl);

  // Current paragraph
  String? get currentParagraph =>
      currentParagraphList?[_currentParagraphIndex] ?? '';

  int get currentParagraphIndex => _currentParagraphIndex;

  Future<void> setCurrentParagraphIndex(int index) async {
    if (_currentParagraphIndex != index) {
      _currentParagraphIndex = index;
      _historyList.first[_keyLastViewedParagraphIndex] = _currentParagraphIndex;
      notifyListeners();
      await sharedPrefs.setString(_keyHistory, historyJsonData);
    }
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
      sharedPrefs.setString(_keyHistory, historyJsonData);
    }
  }

  Future<void> moveNextParagraph() async {
    if (isNotLastParagraph) {
      _currentParagraphIndex++;
      _historyList.first[_keyLastViewedParagraphIndex] = _currentParagraphIndex;
      notifyListeners();
      sharedPrefs.setString(_keyHistory, historyJsonData);
    }
  }

  Future<void> moveToFirstParagraph() async {
    if (isNotFirstParagraph) {
      _currentParagraphIndex = 0;
      _historyList.first[_keyLastViewedParagraphIndex] = _currentParagraphIndex;
      notifyListeners();
      await sharedPrefs.setString(_keyHistory, historyJsonData);
    }
  }

  Future<void> moveToLastParagraph() async {
    if (isNotLastParagraph) {
      _currentParagraphIndex = currentParagraphList!.length - 1;
      _historyList.first[_keyLastViewedParagraphIndex] = _currentParagraphIndex;
      notifyListeners();
      await sharedPrefs.setString(_keyHistory, historyJsonData);
    }
  }
}
