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

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_preferences_notifier.dart';
import '../providers/web_contents_notifier.dart';
import '../providers/activity_notifier.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});

  final String title;

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
  bool _isImportingFavorites = false;
  bool _isExportingFavorites = false;
  bool _isLoadingActivity = false;
  bool _isSavingActivity = false;

  bool get _isImportingOrExporting =>
      _isImportingHistory ||
      _isExportingHistory ||
      _isImportingFavorites ||
      _isExportingFavorites ||
      _isLoadingActivity ||
      _isSavingActivity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pref = context.watch<AppPreferencesNotifier>();

    final settingsList = <Widget>[
      ListTile(
        leading: const Icon(Icons.language_outlined),
        title: Text(l10n.languageLabel),
        trailing: DropdownButton<Locale>(
          value: pref.locale,
          onChanged: (Locale? locale) {
            if (locale != null) pref.setLocale(locale);
          },
          items: const [
            DropdownMenuItem(value: Locale('en'), child: Text('English')),
            DropdownMenuItem(value: Locale('hu'), child: Text('Magyar')),
            DropdownMenuItem(value: Locale('ja'), child: Text('日本語')),
          ],
        ),
      ),
      ListTile(
        leading: const Icon(Icons.dark_mode_outlined),
        title: Text(l10n.darkModeLabel),
        trailing: Switch(
          value: pref.isDarkMode,
          onChanged: (bool value) {
            pref.setDarkMode(value);
          },
        ),
      ),
      ListTile(
        leading: const Icon(Icons.format_size_outlined),
        title: Text(l10n.fontSizeLabel),
        trailing: DropdownButton(
          items: pref.fontSizeFactorList.indexed.map((entry) {
            final (index, factor) = entry;
            return DropdownMenuItem(
              value: index,
              child: Text(
                factor < 0.9
                    ? l10n.fontSizeSmall
                    : factor < 1.1
                    ? l10n.fontSizeMedium
                    : factor < 1.3
                    ? l10n.fontSizeLarge
                    : l10n.fontSizeXLarge,
              ),
            );
          }).toList(),
          value: pref.fontSizeIndex,
          onChanged: (int? index) {
            if (index != null) pref.setFontSizeIndex(index);
          },
        ),
      ),
      ListTile(
        leading: const Icon(Icons.history_outlined),
        title: Text(l10n.historyImportLabel),
        trailing: TextButton.icon(
          label: Text(l10n.pasteButton),
          icon: _isImportingHistory
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const Icon(Icons.paste_outlined),
          onPressed: _isImportingOrExporting ? null : _importHistory,
        ),
      ),
      ListTile(
        leading: const Icon(Icons.history_outlined),
        title: Text(l10n.historyExportLabel),
        trailing: TextButton.icon(
          label: Text(l10n.copyAllButton),
          icon: _isExportingHistory
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const Icon(Icons.copy_all_outlined),
          onPressed: _isImportingOrExporting ? null : _exportHistory,
        ),
      ),
      ListTile(
        leading: const Icon(Icons.star_outlined),
        title: Text(l10n.favoritesImportLabel),
        trailing: TextButton.icon(
          label: Text(l10n.pasteButton),
          icon: _isImportingFavorites
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const Icon(Icons.paste_outlined),
          onPressed: _isImportingOrExporting ? null : _importFavorites,
        ),
      ),
      ListTile(
        leading: const Icon(Icons.star_outlined),
        title: Text(l10n.favoritesExportLabel),
        trailing: TextButton.icon(
          label: Text(l10n.copyAllButton),
          icon: _isExportingFavorites
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const Icon(Icons.copy_all_outlined),
          onPressed: _isImportingOrExporting ? null : _exportFavorites,
        ),
      ),
      ListTile(
        leading: const Icon(Icons.bar_chart_outlined),
        title: Text(l10n.activityRestoreLabel),
        trailing: TextButton.icon(
          label: Text(l10n.restoreButton),
          icon: _isLoadingActivity
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const Icon(Icons.settings_backup_restore_outlined),
          onPressed: _isImportingOrExporting ? null : _loadActivity,
        ),
      ),
      ListTile(
        leading: const Icon(Icons.bar_chart_outlined),
        title: Text(l10n.activityBackupLabel),
        trailing: TextButton.icon(
          label: Text(l10n.backupButton),
          icon: _isSavingActivity
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const Icon(Icons.save_outlined),
          onPressed: _isImportingOrExporting ? null : _saveActivity,
        ),
      ),
    ];

    return Consumer2<WebContentsNotifier, ActivityNotifier>(
      builder: (context, webContentsNotifier, activityNotifier, child) {
        if (webContentsNotifier.isLoading || activityNotifier.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.separated(
          itemCount: settingsList.length,
          separatorBuilder: (context, index) {
            return const Divider(height: 1, thickness: 1);
          },
          itemBuilder: (context, index) {
            return settingsList[index];
          },
        );
      },
    );
  }

  Future<void> _exportHistory() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isExportingHistory = true;
    });

    try {
      final webContentsNotifier = context.read<WebContentsNotifier>();
      final String exportedData = webContentsNotifier.historyTextData;
      await Clipboard.setData(ClipboardData(text: exportedData));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.historyCopySuccessMessage),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.historyExportErrorMessage(e.toString())),
            duration: const Duration(seconds: 3),
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
    final l10n = AppLocalizations.of(context)!;

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

        final results = await Future.wait(lines.map(_addLink));

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
              title: Text(l10n.importCount(successCount)),
              content: Text(
                l10n.importSummary(
                  existsCount,
                  noParagraphCount,
                  invalidUrlCount,
                  errorCount,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.commonOk),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.clipboardEmptyMessage),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.historyImportErrorMessage(e.toString())),
            duration: const Duration(seconds: 3),
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
    final webContentsNotifier = context.read<WebContentsNotifier>();
    if (url.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final document = parser.parse(response.body);
          final pElements = document.getElementsByTagName('p');
          if (pElements.any((element) => element.text.trim().isNotEmpty)) {
            if (webContentsNotifier.containsInHistory(url)) {
              return ImportProcessResult.alreadyExists;
            } else {
              webContentsNotifier.addHistory(url);
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

  Future<void> _exportFavorites() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isExportingFavorites = true;
    });

    try {
      final webContentsNotifier = context.read<WebContentsNotifier>();
      final String exportedData = webContentsNotifier.favoritesTextData;
      await Clipboard.setData(ClipboardData(text: exportedData));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.favoritesCopySuccessMessage),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.favoritesExportErrorMessage(e.toString())),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExportingFavorites = false;
        });
      }
    }
  }

  Future<void> _importFavorites() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isImportingFavorites = true;
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

        final results = await Future.wait(lines.map(_addFavorite));

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
              title: Text(l10n.importCount(successCount)),
              content: Text(
                l10n.importSummary(
                  existsCount,
                  noParagraphCount,
                  invalidUrlCount,
                  errorCount,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.commonOk),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.clipboardEmptyMessage),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.favoritesImportErrorMessage(e.toString())),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImportingFavorites = false;
        });
      }
    }
  }

  Future<ImportProcessResult> _addFavorite(String url) async {
    final webContentsNotifier = context.read<WebContentsNotifier>();
    if (url.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final document = parser.parse(response.body);
          final pElements = document.getElementsByTagName('p');
          if (pElements.any((element) => element.text.trim().isNotEmpty)) {
            if (webContentsNotifier.containsInFavorites(url)) {
              return ImportProcessResult.alreadyExists;
            } else {
              webContentsNotifier.addHistory(url);
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

  Future<void> _saveActivity() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isSavingActivity = true;
    });

    try {
      final activityNotifier = context.read<ActivityNotifier>();
      final String path = await activityNotifier.exportActivity();

      await SharePlus.instance.share(
        ShareParams(files: [XFile(path)], text: 'Activity Backup'),
      );

      if (!mounted) return;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.activityBackupSuccess(path)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingActivity = false;
        });
      }
    }
  }

  Future<void> _loadActivity() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoadingActivity = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        if (!mounted) return;
        final activityNotifier = context.read<ActivityNotifier>();
        await activityNotifier.importActivity(result.files.single.path!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.activityRestoreSuccess),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingActivity = false;
        });
      }
    }
  }
}
