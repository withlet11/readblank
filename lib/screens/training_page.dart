/*
 * content_pane.dart
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
import 'package:provider/provider.dart';

import '../panes/content_pane.dart';
import '../provider/bookmarkedUrlsProvider.dart';

class TrainingPage extends StatefulWidget {
  final String title;

  const TrainingPage({super.key, required this.title});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  int _currentParagraphIndex = 0;
  String? _lastUrl;
  final Map<String, List<String>> _cachedParagraphs = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkedUrlsProvider>(
      builder: (context, provider, child) {
        if (_lastUrl != provider.currentUrl) {
          _lastUrl = provider.currentUrl;
          _currentParagraphIndex = 0;
        }

        if (_cachedParagraphs.containsKey(provider.currentUrl)) {
          return _buildContent(_cachedParagraphs[provider.currentUrl]!);
        } else {
          return FutureBuilder<List<String>>(
            future: _fetchParagraphs(provider.currentUrl),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    color: Colors.lightGreen,
                    backgroundColor: Colors.white,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                _cachedParagraphs[provider.currentUrl] = snapshot.data!;
                return _buildContent(snapshot.data!);
              } else {
                return Center(child: Text('No content found.'));
              }
            },
          );
        }
      },
    );
  }

  Future<List<String>> _fetchParagraphs(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final pElements = document.getElementsByTagName('p');
      return pElements
          .map((element) => element.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
    } else {
      throw Exception('Failed to load page');
    }
  }

  Widget _buildContent(List<String> paragraphs) {
    if (_currentParagraphIndex >= paragraphs.length) {
      _currentParagraphIndex = paragraphs.length - 1;
    }
    if (_currentParagraphIndex < 0) _currentParagraphIndex = 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            SizedBox(
              height: constraints.maxHeight * 0.9,
              child: ContentPane(
                key: ValueKey('${_currentParagraphIndex}_${paragraphs[_currentParagraphIndex]}'),
                paragraph: paragraphs[_currentParagraphIndex],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _currentParagraphIndex > 0
                        ? () => setState(() => _currentParagraphIndex = 0)
                        : null,
                    icon: Icon(Icons.first_page),
                  ),
                  IconButton(
                    onPressed: _currentParagraphIndex > 0
                        ? () => setState(() => _currentParagraphIndex--)
                        : null,
                    icon: Icon(Icons.keyboard_arrow_left),
                  ),
                  DropdownButton<int>(
                    value: _currentParagraphIndex,
                    items: List.generate(
                      paragraphs.length,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text((index + 1).toString()),
                      ),
                    ),
                    onChanged: (int? value) {
                      if (value != null) {
                        setState(() => _currentParagraphIndex = value);
                      }
                    },
                  ),
                  IconButton(
                    onPressed: _currentParagraphIndex < paragraphs.length - 1
                        ? () => setState(() => _currentParagraphIndex++)
                        : null,
                    icon: Icon(Icons.keyboard_arrow_right),
                  ),
                  IconButton(
                    onPressed: _currentParagraphIndex < paragraphs.length - 1
                        ? () => setState(() => _currentParagraphIndex = paragraphs.length - 1)
                        : null,
                    icon: Icon(Icons.last_page),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
