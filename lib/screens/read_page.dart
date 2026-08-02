/*
 * read_page.dart
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
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../views/content_view.dart';
import '../providers/history_notifier.dart';

class ReadPage extends StatefulWidget {
  final String title;

  const ReadPage({super.key, required this.title});

  @override
  State<ReadPage> createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryNotifier>(context, listen: false).fetchCurrentUrl();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 5));
        } else {
          return _buildContent(notifier);
        }
      },
    );
  }

  Widget _buildContent(HistoryNotifier notifier) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            SizedBox(
              height: constraints.maxHeight * 0.9,
              child: ContentView(
                key: ValueKey(
                  '${notifier.currentParagraphIndex}_${notifier.currentParagraph}',
                ),
                paragraph: notifier.currentParagraph.isEmpty
                    ? l10n.urlRequestMessage
                    : notifier.currentParagraph,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: notifier.isNotFirstParagraph
                        ? () => setState(() => notifier.moveToFirstParagraph())
                        : null,
                    icon: const Icon(Icons.first_page),
                  ),
                  IconButton(
                    onPressed: notifier.isNotFirstParagraph
                        ? () => setState(() => notifier.movePreviousParagraph())
                        : null,
                    icon: const Icon(Icons.keyboard_arrow_left),
                  ),
                  DropdownButton<int>(
                    value: notifier.currentParagraphIndex,
                    items: List.generate(
                      notifier.currentParagraphList?.length ?? 0,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text((index + 1).toString()),
                      ),
                    ),
                    onChanged: (int? value) {
                      if (value != null) {
                        setState(() => notifier.currentParagraphIndex = value);
                      }
                    },
                  ),
                  IconButton(
                    onPressed: notifier.isNotLastParagraph
                        ? () => setState(() => notifier.moveNextParagraph())
                        : null,
                    icon: const Icon(Icons.keyboard_arrow_right),
                  ),
                  IconButton(
                    onPressed: notifier.isNotLastParagraph
                        ? () => setState(() => notifier.moveToLastParagraph())
                        : null,
                    icon: const Icon(Icons.last_page),
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
