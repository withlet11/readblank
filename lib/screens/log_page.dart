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

import '../provider/word_list_notifier.dart';

class LogPage extends StatefulWidget {
  final String title;

  const LogPage({super.key, required this.title});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  static const String _keyTimestamp = 'timestamp';
  static const String _keyWord = 'word';

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
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.viewMode == StudyLogViewMode.summary) {
          return _buildSummaryView(provider);
        }

        return _buildListView(provider);
      },
    );
  }

  Widget _buildListView(WordListNotifier provider) {
    final l10n = AppLocalizations.of(context)!;

    return ListView.builder(
      itemCount: provider.studyLog.length,
      itemBuilder: (context, index) {
        final logItem = provider.studyLog[index];
        final word = logItem[_keyWord] ?? l10n.noTitle;
        final timestamp = logItem[_keyTimestamp] ?? '';
        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                  DateFormat.yMd().add_jm().format(DateTime.parse(timestamp)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryView(WordListNotifier provider) {
    final entries = provider.wordCounts.entries.toList();
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
