/*
 * bookmark_provider.dart
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
import 'package:shared_preferences/shared_preferences.dart';

import 'history_provider.dart';

const kDefaultBookmarkedUrls = [
  'https://www.google.com',
  'https://www.wikipedia.org',
  'https://www.debian.org',
  'https://hu.wikipedia.org/wiki/Wikip%C3%A9dia',
];

class BookmarkProvider extends ChangeNotifier {
  // For fetching data from the web
  bool _isLoading = false;
  String? _data;
  String? _error;

  // For storing and retrieving data from SharedPreferences
  final SharedPreferences prefs;
  List<Map<String, dynamic>> _bookmarkList = [];
  Map<String, (String?, List<String>)> cachedContents = {};

  BookmarkProvider(this.prefs) {
    try {
      final bookmarksJson = prefs.getString('bookmarks');
      if (bookmarksJson != null) {
        final decoded = jsonDecode(bookmarksJson);
        if (decoded is List) {
          _bookmarkList = List<Map<String, dynamic>>.from(decoded);
        }
      } else {
        _bookmarkList = [];
      }
    } catch (e) {
      _bookmarkList = [];
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
      for (final entry in _bookmarkList) {
        String url = entry['url'];
        cachedContents[url] = await _fetchData(url);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI to stop spinner
    }
  }

  void update(HistoryProvider historyProvider) {
    cachedContents = historyProvider.cachedContents;
    notifyListeners();
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

  List<Map<String, dynamic>> get bookmarkList => _bookmarkList;

  bool contains(String url) => _bookmarkList.any((e) => e['url'] == url);

  String exportBookmark() =>
      _bookmarkList.map((e) => e['url'] as String).join('\n');

  void add(String url) async {
    _bookmarkList.add({'url': url});
    prefs.setString('bookmarks', jsonEncode(_bookmarkList));
    cachedContents[url] = await _fetchData(url);
    notifyListeners();
  }

  void removeAt(int index) async {
    if (_bookmarkList.length > 1) {
      if (index >= 0 && index < _bookmarkList.length) {
        _bookmarkList.removeAt(index);
        prefs.setString('bookmarks', jsonEncode(_bookmarkList));
        notifyListeners();
      }
    }
  }

  void remove(String url) async {
    final index = _bookmarkList.indexWhere((e) => e['url'] == url);
    removeAt(index);
  }

  void clearAll() async {
    _bookmarkList = [];
    prefs.setString('bookmarks', jsonEncode(_bookmarkList));
    notifyListeners();
  }

  String title(String url) => cachedContents[url]?.$1 ?? 'no title';

  void cacheParagraphList(String url, (String?, List<String>) contents) {
    cachedContents[url] = contents;
  }
}
