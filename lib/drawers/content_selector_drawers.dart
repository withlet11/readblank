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
import '../providers/bookmark_list_notifier.dart';
import '../providers/history_notifier.dart';

class ContentSelectorDrawers extends StatefulWidget {
  const ContentSelectorDrawers({super.key});

  @override
  State<ContentSelectorDrawers> createState() => _ContentSelectorDrawersState();
}

class _ContentSelectorDrawersState extends State<ContentSelectorDrawers>
    with SingleTickerProviderStateMixin {
  static const String _keyTimestamp = 'timestamp';
  static const String _keyUrl = 'url';

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

    return Consumer2<HistoryNotifier, BookmarkListNotifier>(
      builder: (context, historyNotifier, bookmarkListNotifier, child) {
        if (historyNotifier.isLoading || bookmarkListNotifier.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return Drawer(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.history_outlined),
                        text: l10n.historyLabel,
                      ),
                      Tab(
                        icon: const Icon(Icons.bookmark_outline),
                        text: l10n.bookmarksLabel,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _historyListView(historyNotifier, bookmarkListNotifier),
                      _bookmarkListView(historyNotifier, bookmarkListNotifier),
                    ],
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
                        onPressed: _activeIndex == 0
                            ? _clearAllHistory
                            : _deleteAllBookmarks,
                        icon: const Icon(Icons.delete_sweep_outlined),
                        label: Text(
                          _activeIndex == 0
                              ? l10n.allHistoryClearButton
                              : l10n.allBookmarksDeleteButton,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _historyListView(
    HistoryNotifier historyNotifier,
    BookmarkListNotifier bookmarkListNotifier,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: NavigationDrawer(
        header: SizedBox(
          width: double.infinity,
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropdownButton(
                value: 'abc',
                items: [
                  for (final domain in <String>['abc', 'def', 'ghi'])
                    DropdownMenuItem<String>(
                      value: domain,
                      child: Text(domain),
                    ),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        children: [
          for (final entry in historyNotifier.historyList)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 0.0,
                vertical: 0.0,
              ),
              minLeadingWidth: 0,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              leading: IconButton(
                icon: bookmarkListNotifier.contains(entry[_keyUrl])
                    ? const Icon(Icons.star_outlined)
                    : const Icon(Icons.star_border_outlined),
                onPressed: bookmarkListNotifier.contains(entry[_keyUrl])
                    ? null
                    : () {
                        setState(() {
                          bookmarkListNotifier.add(entry[_keyUrl], l10n);
                        });
                      },
              ),
              title: Text(
                historyNotifier.title(entry[_keyUrl]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry[_keyUrl],
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat.yMd().add_jm().format(
                      DateTime.parse(entry[_keyTimestamp]),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              selected: historyNotifier.isSelected(entry[_keyUrl]),
              onTap: () {
                setState(() {
                  historyNotifier.select(entry[_keyUrl]);
                });
                Navigator.pop(context);
              },
              trailing: IconButton(
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                icon: const Icon(Icons.delete_outline),
                onPressed: historyNotifier.historyList.length > 1
                    ? () {
                        setState(() {
                          historyNotifier.remove(entry[_keyUrl]);
                        });
                      }
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _bookmarkListView(
    HistoryNotifier historyNotifier,
    BookmarkListNotifier bookmarkListNotifier,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: NavigationDrawer(
        header: SizedBox(
          width: double.infinity,
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropdownButton(
                value: 'abc',
                items: [
                  for (final domain in <String>['abc', 'def', 'ghi'])
                    DropdownMenuItem<String>(
                      value: domain,
                      child: Text(domain),
                    ),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        children: [
          for (final entry in bookmarkListNotifier.bookmarkList)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 0.0,
                vertical: 0.0,
              ),
              minLeadingWidth: 0,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              leading: IconButton(
                icon: const Icon(Icons.edit_note_outlined),
                onPressed: () {},
              ),
              title: Text(
                bookmarkListNotifier.title(entry[_keyUrl], l10n),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                entry[_keyUrl],
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              selected: historyNotifier.isSelected(entry[_keyUrl]),
              onTap: () {
                setState(() {
                  historyNotifier.select(entry[_keyUrl]);
                });
                Navigator.pop(context);
              },
              trailing: IconButton(
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                icon: const Icon(Icons.delete_outline),
                onPressed: bookmarkListNotifier.bookmarkList.length > 1
                    ? () {
                        setState(() {
                          bookmarkListNotifier.remove(entry[_keyUrl]);
                        });
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
    final settings = context.read<HistoryNotifier>();
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

  void _deleteAllBookmarks() async {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.read<BookmarkListNotifier>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.allBookmarksDeleteButton),
        content: Text(l10n.allBookmarksDeleteConfirmation),
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
}
