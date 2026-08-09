/*
 * content_selector_drawers.dart
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

import '../l10n/app_localizations.dart';
import '../providers/app_preferences_notifier.dart';
import '../providers/link_list_notifier.dart';

class ContentSelectorDrawers extends StatefulWidget {
  const ContentSelectorDrawers({super.key});

  @override
  State<ContentSelectorDrawers> createState() => _ContentSelectorDrawersState();
}

class _ContentSelectorDrawersState extends State<ContentSelectorDrawers>
    with SingleTickerProviderStateMixin {
  static const String _keyUrl = 'url';
  static const String _keyTitle = 'title';
  static const String _keyTimestamp = 'timestamp';
  static const String _keyIsFavorite = 'isFavorite';

  late TabController _tabController;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging ||
        _tabController.index != _activeIndex) {
      setState(() {
        _activeIndex = _tabController.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fontSizeFactor = context
        .watch<AppPreferencesNotifier>()
        .fontSizeFactor;

    return Consumer<LinkListNotifier>(
      builder: (context, linkListNotifier, child) {
        if (linkListNotifier.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return NavigationDrawer(
          header: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history_outlined),
                    Text(
                      l10n.historyLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                      ),
                      icon: Icon(
                        linkListNotifier.isFavoritesOnly
                            ? Icons.filter_alt
                            : Icons.filter_alt_outlined,
                        size: 16 * fontSizeFactor,
                      ),
                      label: Text('Favorites'),
                      onPressed: () {
                        linkListNotifier.isFavoritesOnly =
                            !linkListNotifier.isFavoritesOnly;
                        linkListNotifier.persist();
                      },
                    ),
                    DropdownButton<String?>(
                      value: linkListNotifier.targetLocale,
                      items: [
                        DropdownMenuItem(value: null, child: Text('All🌐')),
                        for (final locale in linkListNotifier.locales)
                          DropdownMenuItem(
                            value: locale,
                            child: Text(
                              '$locale ${_localeNameToEmoji(locale)}',
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        linkListNotifier.targetLocale = value;
                        linkListNotifier.persist();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          children: [
            for (final entry in linkListNotifier.sortedLinkList)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0.0,
                  vertical: 0.0,
                ),
                minLeadingWidth: 0,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
                leading: IconButton(
                  isSelected: entry[_keyIsFavorite] ?? false,
                  icon: const Icon(Icons.star_outline_outlined),
                  selectedIcon: const Icon(Icons.star_outlined),
                  onPressed: () {
                    final isFavorite = entry[_keyIsFavorite] ?? false;
                    entry[_keyIsFavorite] = !isFavorite;
                    linkListNotifier.persist();
                  },
                  disabledColor: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  entry[_keyTitle] ?? l10n.noTitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.dns, size: 12 * fontSizeFactor),
                        Expanded(
                          child: Text(
                            Uri.parse(entry[_keyUrl]).host,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontFamily: 'monospace'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 12 * fontSizeFactor,
                        ),
                        Expanded(
                          child: Text(
                            DateFormat.yMMMd(l10n.localeName).add_jm().format(
                              DateTime.parse(entry[_keyTimestamp]),
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.language_outlined,
                          size: 12 * fontSizeFactor,
                        ),
                        Text(
                          linkListNotifier.getCachedContentLocale(
                                entry[_keyUrl],
                              ) ??
                              '',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: 12),
                        Icon(
                          Icons.data_usage_outlined,
                          size: 12 * fontSizeFactor,
                        ),
                        Text(
                          linkListNotifier.getCachedContentSize(entry[_keyUrl]),
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
                selected: linkListNotifier.isSelected(entry[_keyUrl]),
                onTap: () {
                  linkListNotifier.select(entry[_keyUrl]);
                  Navigator.pop(context);
                },
                trailing: IconButton(
                  style: IconButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  icon: const Icon(Icons.delete_outlined),
                  onPressed: linkListNotifier.linkList.length > 1
                      ? () {
                          linkListNotifier.remove(entry[_keyUrl]);
                        }
                      : null,
                ),
              ),
            const Divider(height: 1),
            SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: _clearAllHistory,
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: Text(l10n.allHistoryClearButton),
                  ),
                ],
              ),
            ),
          ],
          // ),
          // ),
        );
      },
    );
  }

  String _localeNameToEmoji(String localeName) {
    final parts = localeName.replaceAll('-', '_').split('_');

    String contryCode = '';
    if (parts.length > 1) {
      contryCode = parts.last.toUpperCase();
    } else {
      final languageCode = parts.first;
      contryCode = languageCode == 'en'
          ? 'US'
          : languageCode == 'ja'
          ? 'JP'
          : languageCode == 'zh'
          ? 'CN'
          : languageCode.toUpperCase();
    }

    if (contryCode.isEmpty) return '';

    final int firstChar = contryCode.codeUnitAt(0) + 0x1F1A5;
    final int secondChar = contryCode.codeUnitAt(1) + 0x1F1A5;

    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }

  Widget _historyListView(LinkListNotifier linkListNotifier) {
    final l10n = AppLocalizations.of(context)!;
    final fontSizeFactor = context
        .watch<AppPreferencesNotifier>()
        .fontSizeFactor;

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: NavigationDrawer(
        children: [
          for (final entry in linkListNotifier.sortedLinkList)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 0.0,
                vertical: 0.0,
              ),
              minLeadingWidth: 0,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              leading: IconButton(
                isSelected: entry[_keyIsFavorite] ?? false,
                icon: const Icon(Icons.star_outline_outlined),
                selectedIcon: const Icon(Icons.star_outlined),
                onPressed: () {
                  final isFavorite = entry[_keyIsFavorite] ?? false;
                  entry[_keyIsFavorite] = !isFavorite;
                  linkListNotifier.persist();
                },
                disabledColor: Theme.of(context).colorScheme.onSurface,
              ),
              title: Text(
                entry[_keyTitle] ?? l10n.noTitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dns, size: 12 * fontSizeFactor),
                      Text(
                        Uri.parse(entry[_keyUrl]).host,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 12 * fontSizeFactor,
                      ),
                      Text(
                        DateFormat.yMMMd(
                          l10n.localeName,
                        ).add_jm().format(DateTime.parse(entry[_keyTimestamp])),
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.language_outlined, size: 12 * fontSizeFactor),
                      Text(
                        linkListNotifier.getCachedContentLocale(
                              entry[_keyUrl],
                            ) ??
                            '',
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Icons.data_usage_outlined,
                        size: 12 * fontSizeFactor,
                      ),
                      Text(
                        linkListNotifier.getCachedContentSize(entry[_keyUrl]),
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
              selected: linkListNotifier.isSelected(entry[_keyUrl]),
              onTap: () {
                linkListNotifier.select(entry[_keyUrl]);
                Navigator.pop(context);
              },
              trailing: IconButton(
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                icon: const Icon(Icons.delete_outlined),
                onPressed: linkListNotifier.linkList.length > 1
                    ? () {
                        linkListNotifier.remove(entry[_keyUrl]);
                      }
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  void _clearAllHistory() async {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.read<LinkListNotifier>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.allHistoryClearButton),
        content: Text(l10n.allHistoryClearConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonYes),
          ),
        ],
      ),
    );

    if (confirm == true) {
      settings.clearAll();
    }
  }

  // void _deleteAllFavorites() async {
  //   final l10n = AppLocalizations.of(context)!;
  //   final settings = context.read<WebContentsNotifier>();
  //   final confirm = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text(l10n.allFavoritesDeleteButton),
  //       content: Text(l10n.allFavoritesDeleteConfirmation),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: Text(l10n.commonCancel),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           child: Text(l10n.commonYes),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   if (confirm == true) {
  //     settings.clearAllFavorite();
  //   }
  // }
}
