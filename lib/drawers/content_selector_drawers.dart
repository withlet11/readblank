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
import '../provider/bookmark_list_notifier.dart';
import '../provider/history_notifier.dart';

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
      builder: (context, historyProvider, bookmarkProvider, child) {
        if (historyProvider.isLoading || bookmarkProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return Drawer(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Material(
                  color: Colors.lightGreen.shade100,
                  child: SafeArea(
                    bottom: false,
                    child: TabBar(
                      controller: _tabController,
                      unselectedLabelColor: Colors.grey,
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
                ),
                SizedBox(
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
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _historyListView(historyProvider, bookmarkProvider),
                      _bookmarkListView(historyProvider, bookmarkProvider),
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
                        onPressed: _activeIndex == 0
                            ? _clearAllHistory
                            : _deleteAllBookmarks,
                        icon: Icon(
                          Icons.delete_sweep_outlined,
                          color: Colors.red.shade700,
                        ),
                        label: Text(
                          _activeIndex == 0
                              ? l10n.clearAllHistory
                              : l10n.deleteAllBookmarks,
                          style: TextStyle(color: Colors.red.shade700),
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
    HistoryNotifier historyProvider,
    BookmarkListNotifier bookmarkProvider,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (final entry in historyProvider.historyList)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0.0,
              vertical: 0.0,
            ),
            minLeadingWidth: 0,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            leading: IconButton(
              icon: bookmarkProvider.contains(entry[_keyUrl])
                  ? const Icon(Icons.star_outlined)
                  : const Icon(Icons.star_border_outlined),
              onPressed: bookmarkProvider.contains(entry[_keyUrl])
                  ? null
                  : () {
                      setState(() {
                        bookmarkProvider.add(entry[_keyUrl], l10n);
                      });
                    },
            ),
            title: Text(
              historyProvider.title(entry[_keyUrl]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry[_keyUrl],
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat.yMd().add_jm().format(
                    DateTime.parse(entry[_keyTimestamp]),
                  ),
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            selected: historyProvider.isSelected(entry[_keyUrl]),
            selectedTileColor: Colors.lightGreen.shade300,
            selectedColor: Colors.black,
            onTap: () {
              setState(() {
                historyProvider.select(entry[_keyUrl]);
              });
              Navigator.pop(context);
            },
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: historyProvider.historyList.length > 1
                    ? Colors.red.shade700
                    : Colors.grey,
              ),
              onPressed: historyProvider.historyList.length > 1
                  ? () {
                      setState(() {
                        historyProvider.remove(entry[_keyUrl]);
                      });
                    }
                  : null,
            ),
          ),
      ],
    );
  }

  Widget _bookmarkListView(
    HistoryNotifier historyProvider,
    BookmarkListNotifier bookmarkProvider,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (final entry in bookmarkProvider.bookmarkList)
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
              bookmarkProvider.title(entry[_keyUrl], l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              entry[_keyUrl],
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            selected: historyProvider.isSelected(entry[_keyUrl]),
            selectedTileColor: Colors.lightGreen.shade300,
            selectedColor: Colors.black,
            onTap: () {
              setState(() {
                historyProvider.select(entry[_keyUrl]);
              });
              Navigator.pop(context);
            },
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: bookmarkProvider.bookmarkList.length > 1
                    ? Colors.red.shade700
                    : Colors.grey,
              ),
              onPressed: bookmarkProvider.bookmarkList.length > 1
                  ? () {
                      setState(() {
                        bookmarkProvider.remove(entry[_keyUrl]);
                      });
                    }
                  : null,
            ),
          ),
      ],
    );
  }

  void _clearAllHistory() async {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.read<HistoryNotifier>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllHistory),
        content: Text(l10n.confirmClearAllHistory),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yesLabel),
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
        title: Text(l10n.deleteAllBookmarks),
        content: Text(l10n.confirmDeleteAllBookmarks),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yesLabel),
          ),
        ],
      ),
    );

    if (confirm == true) {
      settings.clearAll();
    }
  }
}
