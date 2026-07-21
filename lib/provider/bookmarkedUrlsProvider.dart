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

class BookmarkedUrlsProvider extends ChangeNotifier {
  int _currentIndex = 0;
  List<String> _bookmarkedUrls = [];

  int get currentIndex => _currentIndex;
  List<String> get bookmarkedUrls => _bookmarkedUrls;

  String get currentUrl => _bookmarkedUrls[_currentIndex];

  BookmarkedUrlsProvider(List<String> initialItems) : _bookmarkedUrls = initialItems;

  bool isSelectedItem(String item) {
    return _bookmarkedUrls.indexOf(item) == _currentIndex;
  }

  void selectItem(String item) {
    _currentIndex = _bookmarkedUrls.indexOf(item);
    notifyListeners();
  }

  void setIndex(int index) {
    if (index < 0 || index >= _bookmarkedUrls.length) {
      _currentIndex = index;
      notifyListeners(); // Tells the UI to rebuild
    }
  }

  void addItem(String item) {
    _bookmarkedUrls.add(item);
    notifyListeners();
  }

  void removeItem(String item) {
    if (_bookmarkedUrls.length > 1) {
      if (_bookmarkedUrls.contains(item)) {
        _bookmarkedUrls.remove(item);
        if (_bookmarkedUrls.length > _currentIndex) {
          _currentIndex = _bookmarkedUrls.length - 1;
        }
        notifyListeners();
      }
    }
  }
}
