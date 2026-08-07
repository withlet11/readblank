/*
 * favorite_list_notifier.dart
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

class FavoriteListNotifier extends ChangeNotifier {
  static const String _keyFavorites = 'bookmarks';
  static const String _keyTitle = 'title';
  static const String _keyUrl = 'url';

  // For fetching data from the web
  bool _isLoading = false;
  String? _data;
  String? _error;

  // For storing and retrieving data from SharedPreferences
  final SharedPreferences prefs;
  List<Map<String, dynamic>> _favoriteList = [];
  Map<String, (String?, List<String>, String?, int)> cachedContents = {};

  FavoriteListNotifier(this.prefs) {
    try {
      final favoritesJson = prefs.getString(_keyFavorites);
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

  // For fetching data from the web
  bool get isLoading => _isLoading;

  String? get data => _data;

  Future<void> fetchAllUrls(AppLocalizations l10n) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      for (final entry in _favoriteList) {
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

  void update(HistoryNotifier historyNotifier) {
    cachedContents = historyNotifier.cachedContents;
    notifyListeners();
  }

  Future<(String?, List<String>, String?, int)> _fetchData(
    String url,
    AppLocalizations l10n,
  ) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final lang = document.documentElement?.attributes['lang'];
      final title = document.querySelector(_keyTitle)?.text;
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
      throw Exception(l10n.pageLoadFailMessage);
    }
  }

  List<Map<String, dynamic>> get favoriteList => _favoriteList;

  bool contains(String url) => _favoriteList.any((e) => e[_keyUrl] == url);

  String exportFavorites() =>
      _favoriteList.map((e) => e[_keyUrl] as String).join('\n');

  void add(String url, AppLocalizations l10n) async {
    _favoriteList.add({_keyUrl: url});
    prefs.setString(_keyFavorites, jsonEncode(_favoriteList));
    cachedContents[url] = await _fetchData(url, l10n);
    notifyListeners();
  }

  void removeAt(int index) async {
    if (_favoriteList.length > 1) {
      if (index >= 0 && index < _favoriteList.length) {
        _favoriteList.removeAt(index);
        prefs.setString(_keyFavorites, jsonEncode(_favoriteList));
        notifyListeners();
      }
    }
  }

  void remove(String url) async {
    final index = _favoriteList.indexWhere((e) => e[_keyUrl] == url);
    removeAt(index);
  }

  void clearAll() async {
    _favoriteList = [];
    prefs.setString(_keyFavorites, jsonEncode(_favoriteList));
    notifyListeners();
  }

  String title(String url, AppLocalizations l10n) =>
      cachedContents[url]?.$1 ?? l10n.noTitle;

  void cacheParagraphList(String url, (String?, List<String>, String, int) contents) {
    cachedContents[url] = contents;
  }
}
