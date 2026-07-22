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
import '../provider/bookmarked_urls_provider.dart';

class TrainingPage extends StatefulWidget {
  final String title;

  const TrainingPage({super.key, required this.title});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkedUrlsProvider>(
      builder: (context, provider, child) {
        if (provider.currentParagraphList != null) {
          return _buildContent(provider);
        } else {
          return FutureBuilder<(String?, List<String>)>(
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
                provider.cacheParagraphList(
                  provider.currentUrl,
                  snapshot.data!,
                );
                return _buildContent(provider);
              } else {
                return Center(child: Text('No content found.'));
              }
            },
          );
        }
      },
    );
  }

  Future<(String?, List<String>)> _fetchParagraphs(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final title = document.querySelector('title')?.text;
      final pElements = document.getElementsByTagName('p');
      return (title, pElements
          .map((element) => element.text.trim())
          .where((text) => text.isNotEmpty)
          .toList());
    } else {
      throw Exception('Failed to load page');
    }
  }

  Widget _buildContent(BookmarkedUrlsProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            SizedBox(
              height: constraints.maxHeight * 0.9,
              child: ContentPane(
                key: ValueKey(
                  '${provider.currentParagraphIndex}_${provider.currentParagraph}',
                ),
                paragraph: provider.currentParagraph,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: provider.isNotFirstParagraph
                        ? () => setState(() => provider.moveToFirstParagraph())
                        : null,
                    icon: Icon(Icons.first_page),
                  ),
                  IconButton(
                    onPressed: provider.isNotFirstParagraph
                        ? () => setState(() => provider.movePreviousParagraph())
                        : null,
                    icon: Icon(Icons.keyboard_arrow_left),
                  ),
                  DropdownButton<int>(
                    value: provider.currentParagraphIndex,
                    items: List.generate(
                      provider.currentParagraphList?.length ?? 0,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text((index + 1).toString()),
                      ),
                    ),
                    onChanged: (int? value) {
                      if (value != null) {
                        setState(() => provider.currentParagraphIndex = value);
                      }
                    },
                  ),
                  IconButton(
                    onPressed: provider.isNotLastParagraph
                        ? () => setState(() => provider.moveNextParagraph())
                        : null,
                    icon: Icon(Icons.keyboard_arrow_right),
                  ),
                  IconButton(
                    onPressed: provider.isNotLastParagraph
                        ? () => setState(() => provider.moveToLastParagraph())
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
