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

import '../views/daily_chart_view.dart';
import '../providers/app_preferences_notifier.dart';
import '../providers/word_list_notifier.dart';
import '../views/weekly_chart_view.dart';

class ActivityPage extends StatefulWidget {
  final String title;

  const ActivityPage({super.key, required this.title});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  static final DateTime _startDate = DateTime(2026, 7, 1);
  final DailyChartViewController _dailyChartController = DailyChartViewController();
  final WeeklyChartViewController _weeklyChartController = WeeklyChartViewController();
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
        final isSummary = notifier.viewMode == StudyLogViewMode.weekly;
        final hasData = isSummary
            ? notifier.wordCounts.isNotEmpty
            : notifier.studyLog.isNotEmpty;

        if (notifier.isLoading && !hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final view = isSummary
            ? _buildWeeklyView(notifier)
            : _buildDailyView(notifier);

        return Stack(
          children: [
            view,
            if (notifier.isLoading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        );
      },
    );
  }

  DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool _isStartDateOrBefore(DateTime date) {
    return date.isAtSameMomentAs(_startDate) || date.isBefore(_startDate);
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
    final previousData = _isStartDateOrBefore(_selectedDate)
        ? <int>[]
        : notifier.getHalfHourlyCountList(_previousDate(_selectedDate));
    final nextData = _isTodayOrAfter(_selectedDate)
        ? <int>[]
        : notifier.getHalfHourlyCountList(_nextDate(_selectedDate));
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
                  onPressed: _isStartDateOrBefore(_selectedDate)
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
                  l10n.dateFormatForDailyChart(_selectedDate),
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
            DailyChartView(
              controller: _dailyChartController,
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
              onSwipeRight: _isStartDateOrBefore(_selectedDate)
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
        ),
      ],
    );
  }

  DateTime _getFirstDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  DateTime _getLastDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 7));
  }

  DateTime get firstDayInThisWeek => _getFirstDayOfWeek(today);

  bool _isInStartWeekOrBefore(DateTime date) {
    return _getFirstDayOfWeek(
          date,
        ).isAtSameMomentAs(_getFirstDayOfWeek(_startDate)) ||
        date.isBefore(_startDate);
  }

  bool _isInThisWeek(DateTime date) {
    return _getFirstDayOfWeek(date).isAtSameMomentAs(_getFirstDayOfWeek(today));
  }

  bool _isInThisWeekOrAfter(DateTime date) {
    return _isInThisWeek(date) || date.isAfter(today);
  }

  DateTime _previousWeek(DateTime date) {
    return _getFirstDayOfWeek(date).subtract(const Duration(days: 7));
  }

  DateTime _nextWeek(DateTime date) {
    return _getFirstDayOfWeek(date).add(const Duration(days: 7));
  }

  bool _isInSameYear(DateTime date1, DateTime date2) {
    return date1.year == date2.year;
  }

  bool _isInSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  Widget _buildWeeklyView(WordListNotifier notifier) {
    final l10n = AppLocalizations.of(context)!;
    final prefs = context.watch<AppPreferencesNotifier>();
    final currentData = notifier.getDailyCountList(_selectedDate);
    final previousData = _isInStartWeekOrBefore(_selectedDate)
        ? <int>[]
        : notifier.getDailyCountList(_previousWeek(_selectedDate));
    final nextData = _isInThisWeekOrAfter(_selectedDate)
        ? <int>[]
        : notifier.getDailyCountList(_nextWeek(_selectedDate));
    final entries = notifier.getWeeklyWordCounts(_selectedDate).entries.toList();

    return Column(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_left),
                  onPressed: _isStartDateOrBefore(_selectedDate)
                      ? null
                      : () {
                          setState(() {
                            _selectedDate = _previousWeek(_selectedDate);
                          });
                          context.read<WordListNotifier>().loadWeeklyData(
                            _selectedDate,
                          );
                        },
                ),
                Expanded(
                  child: Text(
                    // en
                    // December 29, 2025 − January 4, 2026
                    // July 27 − August 2
                    // August 3 − 9
                    // hu
                    // 2025. december 29. − 2026. január 4.
                    // július 24. − augusztus 2.
                    // augusztus 3−9.
                    // ja
                    // 2025年12月29日〜2026年1月4日
                    // 7月27日〜8月2日
                    // 8月3日〜9日
                    _isInSameMonth(
                          _getFirstDayOfWeek(_selectedDate),
                          _getLastDayOfWeek(_selectedDate),
                        )
                        ? l10n.dateFormatForWeeklyChartInSameMonth(
                            _getFirstDayOfWeek(_selectedDate),
                            _getLastDayOfWeek(_selectedDate),
                          )
                        : _isInSameYear(
                            _getFirstDayOfWeek(_selectedDate),
                            _getLastDayOfWeek(_selectedDate),
                          )
                        ? l10n.dateFormatForWeeklyChartInSameYear(
                            _getFirstDayOfWeek(_selectedDate),
                            _getLastDayOfWeek(_selectedDate),
                          )
                        : l10n.dateFormatForWeeklyChart(
                            _getFirstDayOfWeek(_selectedDate),
                            _getLastDayOfWeek(_selectedDate),
                          ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_right),
                  onPressed: _isTodayOrAfter(_selectedDate)
                      ? null
                      : () {
                          setState(() {
                            _selectedDate = _nextWeek(_selectedDate);
                          });
                          context.read<WordListNotifier>().loadWeeklyData(
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
                Text(l10n.wordCount(notifier.getWeeklyWordCount(_selectedDate))),
              ],
            ),
            WeeklyChartView(
              controller: _weeklyChartController,
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
                        _selectedDate = _nextWeek(_selectedDate);
                      });
                      context.read<WordListNotifier>().loadWeeklyData(
                        _selectedDate,
                      );
                    },
              onSwipeRight: _isInStartWeekOrBefore(_selectedDate)
                  ? null
                  : () {
                      setState(() {
                        _selectedDate = _previousWeek(_selectedDate);
                      });
                      context.read<WordListNotifier>().loadWeeklyData(
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
        ),
      ],
    );
  }
}
