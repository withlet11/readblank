/*
 * bookmarkedUrlsProvider.dart
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
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const kDefaultBookmarkedUrls = [
  'https://www.google.com',
  'https://www.wikipedia.org',
  'https://www.debian.org',
  'https://hu.wikipedia.org/wiki/Wikip%C3%A9dia',
];

class BookmarkedUrlsProvider extends ChangeNotifier {
  // For fetching data from the web
  bool _isLoading = false;
  String? _data;
  String? _error;

  // For storing and retrieving data from SharedPreferences
  final SharedPreferences prefs;
  List<String> _bookmarkList = [];
  int _index = 0; // internal variable of _currentBookmarkIndex
  final Map<String, (String?, List<String>)> _cachedContents = {};
  int _currentParagraphIndex = 0;

  BookmarkedUrlsProvider(this.prefs) {
    final list = prefs.getStringList('bookmarks');
    _bookmarkList = (list != null && list.isNotEmpty)
        ? list
        : List.from(kDefaultBookmarkedUrls);
  }

  // For fetching data from the web
  bool get isLoading => _isLoading;

  String? get data => _data;

  Future<void> fetchAllUrls() async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Notify UI to show spinner

    try {
      for (final url in _bookmarkList) {
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

    final contents = await _fetchData(currentUrl);
    _cachedContents[currentUrl] = contents;

    _isLoading = false;
    notifyListeners(); // Notify UI to stop spinner
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

  // For storing and retrieving data from SharedPreferences
  int get _currentBookmarkIndex => _index;

  set _currentBookmarkIndex(int index) {
    _index = index;
    _currentParagraphIndex = 0;
  }

  List<String> get bookmarkList => _bookmarkList;

  String get currentUrl => _bookmarkList[_currentBookmarkIndex];

  String get currentDomainName => Uri.parse(
    _bookmarkList[_currentBookmarkIndex],
  ).host.replaceFirst('www.', '');

  String get currentTitle => _cachedContents[currentUrl]?.$1 ?? currentUrl;

  bool isSelectedBookmark(String bookmark) =>
      _bookmarkList.indexOf(bookmark) == _currentBookmarkIndex;

  bool containsBookmark(String bookmark) => _bookmarkList.contains(bookmark);

  void selectBookmark(String bookmark) {
    _currentBookmarkIndex = _bookmarkList.indexOf(bookmark);
    notifyListeners();
  }

  void addBookmark(String bookmark) async {
    _bookmarkList.add(bookmark);
    prefs.setStringList('bookmarks', _bookmarkList);
    _cachedContents[bookmark] = await _fetchData(bookmark);
    notifyListeners();
  }

  void removeBookmark(int index) async {
    if (_bookmarkList.length > 1) {
      if (index >= 0 && index < _bookmarkList.length) {
        _bookmarkList.removeAt(index);
        if (_currentBookmarkIndex >= _bookmarkList.length) {
          _currentBookmarkIndex = _bookmarkList.length - 1;
        }
        prefs.setStringList('bookmarks', _bookmarkList);
        notifyListeners();
      }
    }
  }

  void removeBookMarkWithUrl(String url) async {
    final index = _bookmarkList.indexOf(url);
    removeBookmark(index);
  }

  void restoreDefaultList() async {
    _bookmarkList = List.from(kDefaultBookmarkedUrls);
    prefs.setStringList('bookmarks', _bookmarkList);
    _currentBookmarkIndex = 0;
    notifyListeners();
  }

  String title(String url) => _cachedContents[url]?.$1 ?? 'no title';

  List<String>? get currentParagraphList => _cachedContents[currentUrl]?.$2;

  void cacheParagraphList(String url, (String?, List<String>) contents) {
    _cachedContents[url] = contents;
    _currentBookmarkIndex = _bookmarkList.indexOf(url);
  }

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
