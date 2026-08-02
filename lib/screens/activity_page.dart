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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:readblank/l10n/app_localizations.dart';

import '../charts/bar_chart.dart';
import '../providers/app_preferences_notifier.dart';
import '../providers/word_list_notifier.dart';

class ActivityPage extends StatefulWidget {
  final String title;

  const ActivityPage({super.key, required this.title});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  static final DateTime _startDate = DateTime(2026, 7, 1);
  final BarChartController _chartController = BarChartController();
  late DateTime _selectedDate = today;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WordListNotifier>().loadDailyData(_selectedDate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WordListNotifier>(
      builder: (context, notifier, child) {
        final isSummary = notifier.viewMode == StudyLogViewMode.summary;
        final hasData = isSummary
            ? notifier.wordCounts.isNotEmpty
            : notifier.studyLog.isNotEmpty;

        if (notifier.isLoading && !hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final view = isSummary
            ? _buildSummaryView(notifier)
            : _buildDailyView(notifier);

        if (notifier.isLoading) {
          return Stack(
            children: [
              view,
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(minHeight: 2),
              ),
            ],
          );
        }

        return view;
      },
    );
  }

  DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool _isStartDate(DateTime date) {
    return date.isAtSameMomentAs(_startDate);
  }

  bool _isToday(DateTime date) {
    return date.isAtSameMomentAs(today);
  }

  bool _isTodayOrAfter(DateTime date) {
    return date.isAtSameMomentAs(today) || date.isAfter(today);
  }

  DateTime _previousDate(DateTime date) {
    return _selectedDate.subtract(const Duration(days: 1));
  }

  DateTime _nextDate(DateTime date) {
    return _selectedDate.add(const Duration(days: 1));
  }

  Widget _buildDailyView(WordListNotifier notifier) {
    final l10n = AppLocalizations.of(context)!;
    final prefs = context.watch<AppPreferencesNotifier>();
    final currentData = notifier.getHalfHourlyCountList(_selectedDate);
    final previousData = notifier.getHalfHourlyCountList(
      _previousDate(_selectedDate),
    );
    final nextData = notifier.getHalfHourlyCountList(_nextDate(_selectedDate));
    final entries = notifier.getDailyWordCounts(_selectedDate).entries.toList();

    return Column(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_left),
                  onPressed: _isStartDate(_selectedDate)
                      ? null
                      : () {
                          setState(() {
                            _selectedDate = _previousDate(_selectedDate);
                          });
                          context.read<WordListNotifier>().loadDailyData(
                            _selectedDate,
                          );
                        },
                ),
                Text(
                  DateFormat.MMMMEEEEd(l10n.localeName).format(_selectedDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_right),
                  onPressed: _isTodayOrAfter(_selectedDate)
                      ? null
                      : () {
                          setState(() {
                            _selectedDate = _nextDate(_selectedDate);
                          });
                          context.read<WordListNotifier>().loadDailyData(
                            _selectedDate,
                          );
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
            BarChart(
              controller: _chartController,
              currentData: currentData,
              previousData: previousData,
              nextData: nextData,
              barColor: Theme.of(context).colorScheme.tertiary,
              textColor: Theme.of(context).colorScheme.onSurface,
              fontSize: 12.0 * prefs.fontSizeFactor,
              onSwipeLeft: _isToday(_selectedDate)
                  ? null
                  : () {
                      setState(() {
                        _selectedDate = _nextDate(_selectedDate);
                      });
                      context.read<WordListNotifier>().loadDailyData(
                        _selectedDate,
                      );
                    },
              onSwipeRight: _isStartDate(_selectedDate)
                  ? null
                  : () {
                      setState(() {
                        _selectedDate = _previousDate(_selectedDate);
                      });
                      context.read<WordListNotifier>().loadDailyData(
                        _selectedDate,
                      );
                    },
            ),
            SizedBox(height: 16),
            Divider(height: 1),
            Text(
              'Read Words',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        Expanded(
          child: ListView.separated(
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
          ),

          // child: ListView.builder(
          //   itemCount: notifier.studyLog.length,
          //   itemBuilder: (context, index) {
          //     final logItem = notifier.studyLog[index];
          //     final word = logItem[_keyWord] ?? l10n.noTitle;
          //     final timestamp = logItem[_keyTimestamp] ?? '';
          //     return Container(
          //       height: 48,
          //       padding: const EdgeInsets.symmetric(
          //         vertical: 8,
          //         horizontal: 16,
          //       ),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Flexible(
          //             flex: 2,
          //             child: Text(
          //               word,
          //               style: Theme.of(context).textTheme.bodyMedium,
          //               maxLines: 1,
          //               overflow: TextOverflow.ellipsis,
          //             ),
          //           ),
          //           Flexible(
          //             flex: 2,
          //             child: Text(
          //               DateFormat.yMd().add_jm().format(
          //                 DateTime.parse(timestamp),
          //               ),
          //               style: Theme.of(context).textTheme.bodySmall,
          //             ),
          //           ),
          //         ],
          //       ),
          //     );
          //   },
          // ),
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
