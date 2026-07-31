/*
 * log_page.dart
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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:readblank/l10n/app_localizations.dart';

import '../charts/bar_chart.dart';
import '../providers/app_preferences_notifier.dart';
import '../providers/word_list_notifier.dart';

class LogPage extends StatefulWidget {
  final String title;

  const LogPage({super.key, required this.title});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  static const String _keyTimestamp = 'timestamp';
  static const String _keyWord = 'word';
  static final DateTime _startDate = DateTime(2026, 7, 1);

  late DateTime _selectedDate = ((now) =>
      DateTime(now.year, now.month, now.day))(DateTime.now());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WordListNotifier>().loadLogs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WordListNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (notifier.viewMode == StudyLogViewMode.summary) {
          return _buildSummaryView(notifier);
        }

        return _buildListView(notifier);
      },
    );
  }

  Widget _buildListView(WordListNotifier notifier) {
    final l10n = AppLocalizations.of(context)!;
    final prefs = context.watch<AppPreferencesNotifier>();
    final data = notifier.getHalfHourlyCountList(_selectedDate);

    return Column(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_left),
                  onPressed:
                      _startDate.difference(_selectedDate) >=
                          const Duration(days: 0)
                      ? null
                      : () {
                          setState(() {
                            _selectedDate = _selectedDate.subtract(
                              const Duration(days: 1),
                            );
                          });
                        },
                ),
                Text(
                  DateFormat.MMMMEEEEd(l10n.localeName).format(_selectedDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_right),

                  onPressed:
                      DateTime.now().difference(_selectedDate) <=
                          const Duration(days: 1)
                      ? null
                      : () {
                          setState(() {
                            _selectedDate = _selectedDate.add(
                              const Duration(days: 1),
                            );
                          });
                        },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.abc),
                Text(l10n.wordCount(notifier.getDayWordCount(_selectedDate))),
              ],
            ),
            SizedBox(
              height: 180,
              width: double.infinity,
              child: CustomPaint(
                painter: BarChartPainter(
                  data: data,
                  barColor: Theme.of(context).colorScheme.tertiary,
                  textColor: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12.0 * prefs.fontSizeFactor,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: notifier.studyLog.length,
            itemBuilder: (context, index) {
              final logItem = notifier.studyLog[index];
              final word = logItem[_keyWord] ?? l10n.noTitle;
              final timestamp = logItem[_keyTimestamp] ?? '';
              return Container(
                height: 48,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Text(
                        word,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Text(
                        DateFormat.yMd().add_jm().format(
                          DateTime.parse(timestamp),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryView(WordListNotifier notifier) {
    final entries = notifier.wordCounts.entries.toList();
    return ListView.separated(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          title: Text(
            entry.key,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Text(
            entry.value.toString(),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(height: 1, thickness: 1);
      },
    );
  }
}
