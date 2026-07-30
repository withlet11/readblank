/*
 * bookmark_list_notifier.dart
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

import '../l10n/app_localizations.dart';
import 'history_notifier.dart';

const kDefaultBookmarkedUrls = [
  'https://www.google.com',
  'https://www.wikipedia.org',
  'https://www.debian.org',
  'https://hu.wikipedia.org/wiki/Wikip%C3%A9dia',
];

class BookmarkListNotifier extends ChangeNotifier {
  static const String _keyBookmarks = 'bookmarks';
  static const String _keyTitle = 'title';
  static const String _keyUrl = 'url';

  // For fetching data from the web
  bool _isLoading = false;
  String? _data;
  String? _error;

  // For storing and retrieving data from SharedPreferences
  final SharedPreferences prefs;
  List<Map<String, dynamic>> _bookmarkList = [];
  Map<String, (String?, List<String>)> cachedContents = {};

  BookmarkListNotifier(this.prefs) {
    try {
      final bookmarksJson = prefs.getString(_keyBookmarks);
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

  Future<void> fetchAllUrls(AppLocalizations l10n) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      for (final entry in _bookmarkList) {
        String url = entry[_keyUrl];
        cachedContents[url] = await _fetchData(url, l10n);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void update(HistoryNotifier historyProvider) {
    cachedContents = historyProvider.cachedContents;
    notifyListeners();
  }

  Future<(String?, List<String>)> _fetchData(
    String url,
    AppLocalizations l10n,
  ) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final title = document.querySelector(_keyTitle)?.text;
      final pElements = document.getElementsByTagName('p');
      return (
        title,
        pElements
            .map((element) => element.text.trim())
            .where((text) => text.isNotEmpty)
            .toList(),
      );
    } else {
      throw Exception(l10n.failedToLoadPage);
    }
  }

  List<Map<String, dynamic>> get bookmarkList => _bookmarkList;

  bool contains(String url) => _bookmarkList.any((e) => e[_keyUrl] == url);

  String exportBookmark() =>
      _bookmarkList.map((e) => e[_keyUrl] as String).join('\n');

  void add(String url, AppLocalizations l10n) async {
    _bookmarkList.add({_keyUrl: url});
    prefs.setString(_keyBookmarks, jsonEncode(_bookmarkList));
    cachedContents[url] = await _fetchData(url, l10n);
    notifyListeners();
  }

  void removeAt(int index) async {
    if (_bookmarkList.length > 1) {
      if (index >= 0 && index < _bookmarkList.length) {
        _bookmarkList.removeAt(index);
        prefs.setString(_keyBookmarks, jsonEncode(_bookmarkList));
        notifyListeners();
      }
    }
  }

  void remove(String url) async {
    final index = _bookmarkList.indexWhere((e) => e[_keyUrl] == url);
    removeAt(index);
  }

  void clearAll() async {
    _bookmarkList = [];
    prefs.setString(_keyBookmarks, jsonEncode(_bookmarkList));
    notifyListeners();
  }

  String title(String url, AppLocalizations l10n) =>
      cachedContents[url]?.$1 ?? l10n.noTitleLabel;

  void cacheParagraphList(String url, (String?, List<String>) contents) {
    cachedContents[url] = contents;
  }
}
