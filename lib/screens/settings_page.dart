/*
 * settings_page.dart
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
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../db/word_list_provider.dart';
import '../provider/bookmark_provider.dart';
import '../provider/history_provider.dart';

class SettingsPage extends StatefulWidget {
  final String title;

  const SettingsPage({super.key, required this.title});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

enum ImportProcessResult {
  success,
  alreadyExists,
  noParagraph,
  invalidUrl,
  noUrl,
  error,
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isImportingHistory = false;
  bool _isExportingHistory = false;
  bool _isImportingBookmark = false;
  bool _isExportingBookmark = false;

  bool get _isImportingOrExporting =>
      _isImportingHistory ||
      _isExportingHistory ||
      _isImportingBookmark ||
      _isExportingBookmark;

  @override
  Widget build(BuildContext context) {
    final settingsList = <Widget>[
      ListTile(
        leading: Icon(Icons.history_outlined),
        title: Text('Import history'),
        trailing: TextButton.icon(
          label: Text('Paste'),
          icon: _isImportingHistory
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Icon(Icons.paste_rounded),
          onPressed: _isImportingOrExporting ? null : _importHistory,
        ),
      ),
      ListTile(
        leading: Icon(Icons.history_outlined),
        title: Text('Export history'),
        trailing: TextButton.icon(
          label: Text('Copy all'),
          icon: _isExportingHistory
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Icon(Icons.copy_all_outlined),
          onPressed: _isImportingOrExporting ? null : _exportHistory,
        ),
      ),
      ListTile(
        leading: Icon(Icons.bookmarks_outlined),
        title: Text('Import bookmarks'),
        trailing: TextButton.icon(
          label: Text('Paste'),
          icon: _isImportingBookmark
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Icon(Icons.paste_rounded),
          onPressed: _isImportingOrExporting ? null : _importBookmark,
        ),
      ),
      ListTile(
        leading: Icon(Icons.bookmarks_outlined),
        title: Text('Export bookmarks'),
        trailing: TextButton.icon(
          label: Text('Copy all'),
          icon: _isExportingBookmark
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Icon(Icons.copy_all_outlined),
          onPressed: _isImportingOrExporting ? null : _exportBookmark,
        ),
      ),
    ];

    return Consumer3<HistoryProvider, BookmarkProvider, WordListProvider>(
      builder:
          (
            context,
            historyProvider,
            bookmarkProvider,
            wordListProvider,
            child,
          ) {
            if (historyProvider.isLoading ||
                bookmarkProvider.isLoading ||
                wordListProvider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView.separated(
              itemCount: settingsList.length,
              separatorBuilder: (context, index) {
                return const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Colors.grey,
                );
              },
              itemBuilder: (context, index) {
                return settingsList[index];
              },
            );
          },
    );
  }

  Future<void> _exportHistory() async {
    setState(() {
      _isExportingHistory = true;
    });

    try {
      final historyProvider = context.read<HistoryProvider>();
      final String exportedData = historyProvider.exportHistory();
      await Clipboard.setData(ClipboardData(text: exportedData));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('History copied to clipboard'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export history: $e'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExportingHistory = false;
        });
      }
    }
  }

  Future<void> _importHistory() async {
    setState(() {
      _isImportingHistory = true;
    });
    try {
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      final String? copiedText = data?.text;

      if (copiedText != null && copiedText.isNotEmpty) {
        final List<String> lines = copiedText
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();

        int successCount = 0;
        int existsCount = 0;
        int noParagraphCount = 0;
        int invalidUrlCount = 0;
        int errorCount = 0;

        final results = await Future.wait(lines.map((line) => _addLink(line)));

        for (final result in results) {
          switch (result) {
            case ImportProcessResult.success:
              ++successCount;
              break;
            case ImportProcessResult.alreadyExists:
              ++existsCount;
              break;
            case ImportProcessResult.noParagraph:
              ++noParagraphCount;
              break;
            case ImportProcessResult.invalidUrl:
              ++invalidUrlCount;
              break;
            default:
              ++errorCount;
          }
        }

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('$successCount imported'),
              content: Text(
                'Already exists: $existsCount\n'
                'No paragraph: $noParagraphCount\n'
                'Invalid URL: $invalidUrlCount\n'
                'Error: $errorCount',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Clipboard empty. Please copy URL List'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import history: $e'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImportingHistory = false;
        });
      }
    }
  }

  Future<ImportProcessResult> _addLink(String url) async {
    final historyProvider = context.read<HistoryProvider>();
    if (url.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final document = parser.parse(response.body);
          final pElements = document.getElementsByTagName('p');
          if (pElements.any((element) => element.text.trim().isNotEmpty)) {
            if (historyProvider.contains(url)) {
              return ImportProcessResult.alreadyExists;
            } else {
              historyProvider.add(url);
              return ImportProcessResult.success;
            }
          } else {
            return ImportProcessResult.noParagraph;
          }
        } else {
          return ImportProcessResult.invalidUrl;
        }
      } catch (e) {
        return ImportProcessResult.error;
      }
    } else {
      return ImportProcessResult.noUrl;
    }
  }

  Future<void> _exportBookmark() async {
    setState(() {
      _isExportingBookmark = true;
    });

    try {
      final bookmarkProvider = context.read<BookmarkProvider>();
      final String exportedData = bookmarkProvider.exportBookmark();
      await Clipboard.setData(ClipboardData(text: exportedData));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bookmarks copied to clipboard'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export bookmarks: $e'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExportingBookmark = false;
        });
      }
    }
  }

  Future<void> _importBookmark() async {
    setState(() {
      _isImportingBookmark = true;
    });
    try {
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      final String? copiedText = data?.text;

      if (copiedText != null && copiedText.isNotEmpty) {
        final List<String> lines = copiedText
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();

        int successCount = 0;
        int existsCount = 0;
        int noParagraphCount = 0;
        int invalidUrlCount = 0;
        int errorCount = 0;

        final results = await Future.wait(lines.map(_addBookmark));

        for (final result in results) {
          switch (result) {
            case ImportProcessResult.success:
              ++successCount;
              break;
            case ImportProcessResult.alreadyExists:
              ++existsCount;
              break;
            case ImportProcessResult.noParagraph:
              ++noParagraphCount;
              break;
            case ImportProcessResult.invalidUrl:
              ++invalidUrlCount;
              break;
            default:
              ++errorCount;
          }
        }

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('$successCount imported'),
              content: Text(
                'Already exists: $existsCount\n'
                'No paragraph: $noParagraphCount\n'
                'Invalid URL: $invalidUrlCount\n'
                'Error: $errorCount',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Clipboard empty. Please copy URL List'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import bookmarks: $e'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImportingBookmark = false;
        });
      }
    }
  }

  Future<ImportProcessResult> _addBookmark(String url) async {
    final bookmakrProvider = context.read<BookmarkProvider>();
    if (url.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final document = parser.parse(response.body);
          final pElements = document.getElementsByTagName('p');
          if (pElements.any((element) => element.text.trim().isNotEmpty)) {
            if (bookmakrProvider.contains(url)) {
              return ImportProcessResult.alreadyExists;
            } else {
              bookmakrProvider.add(url);
              return ImportProcessResult.success;
            }
          } else {
            return ImportProcessResult.noParagraph;
          }
        } else {
          return ImportProcessResult.invalidUrl;
        }
      } catch (e) {
        return ImportProcessResult.error;
      }
    } else {
      return ImportProcessResult.noUrl;
    }
  }
}
