/*
 * bookmark_drawers.dart
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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:readblank/provider/history_provider.dart';

import '../provider/bookmarked_urls_provider.dart';

class BookmarkDrawers extends StatefulWidget {
  const BookmarkDrawers({super.key});

  @override
  State<BookmarkDrawers> createState() => _BookmarkDrawersState();
}

class _BookmarkDrawersState extends State<BookmarkDrawers> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<HistoryProvider, BookmarkedUrlsProvider>(
      builder: (context, provider, bookmarkProvider, child) {
        return Drawer(
          child: DefaultTabController(
            length: 2,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                PinnedHeaderSliver(
                  child: Material(
                    color: Colors.lightGreen[100],
                    child: SafeArea(
                      bottom: false,
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: [
                          Tab(
                            icon: Icon(Icons.history_outlined),
                            text: 'History',
                          ),
                          Tab(
                            icon: Icon(Icons.bookmark_outline),
                            text: 'Bookmarks',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: Icon(
                            Icons.cleaning_services_outlined,
                            color: Colors.red[700],
                          ),
                          onPressed: _clearAllHistory,
                        ),
                      ),
                      Builder(
                        builder: (context) => IconButton(
                          icon: Icon(Icons.add_link_outlined),
                          onPressed: _addBookmark,
                        ),
                      ),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: TabBarView(
                    children: [
                      _historyListView(provider),
                      _bookmarkListView(bookmarkProvider),
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

  Widget _historyListView(HistoryProvider provider) {
    return Column(
      children: [
        for (final entry in provider.historyList)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0.0,
              vertical: 0.0,
            ),
            minLeadingWidth: 0,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            leading: IconButton(
              icon: Icon(Icons.star_border_outlined),
              onPressed: () {},
            ),
            title: Text(
              provider.title(entry['url']),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['url'],
                  style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat.yMd().add_jm().format(
                    DateTime.parse(entry['timestamp']),
                  ),
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            selected: provider.isSelected(entry['url']),
            selectedTileColor: Colors.lightGreen.shade200,
            selectedColor: Colors.black,
            onTap: () {
              setState(() {
                provider.select(entry['url']);
              });
              Navigator.pop(context);
            },
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: provider.historyList.length > 1
                    ? Colors.red[700]
                    : Colors.grey,
              ),
              onPressed: provider.historyList.length > 1
                  ? () {
                      setState(() {
                        provider.remove(entry['url']);
                      });
                    }
                  : null,
            ),
          ),
      ],
    );
  }

  Widget _bookmarkListView(BookmarkedUrlsProvider provider) {
    return Column(
      children: [
        for (final entry in provider.bookmarkList)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0.0,
              vertical: 0.0,
            ),
            minLeadingWidth: 0,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            leading: IconButton(
              icon: Icon(Icons.star_border_outlined),
              onPressed: () {},
            ),
            title: Text(
              provider.title(entry),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              entry,
              style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            selected: provider.isSelectedBookmark(entry),
            selectedTileColor: Colors.lightGreen.shade200,
            selectedColor: Colors.black,
            onTap: () {
              setState(() {
                provider.selectBookmark(entry);
              });
              Navigator.pop(context);
            },
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: provider.bookmarkList.length > 1
                    ? Colors.red[700]
                    : Colors.grey,
              ),
              onPressed: provider.bookmarkList.length > 1
                  ? () {
                      setState(() {
                        provider.removeBookMarkWithUrl(entry);
                      });
                    }
                  : null,
            ),
          ),
      ],
    );
  }

  void _clearAllHistory() async {
    final settings = context.read<HistoryProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All History'),
        content: Text('Are you sure you want to clear all history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Restore'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      settings.clearAll();
    }
  }

  void _addBookmark() async {
    final callersContext = context;
    final settings = callersContext.read<HistoryProvider>();
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String? copiedText = data?.text;
    if (copiedText != null && copiedText.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(copiedText));
        if (response.statusCode == 200) {
          final document = parser.parse(response.body);
          final pElements = document.getElementsByTagName('p');
          if (pElements.any((element) => element.text.trim().isNotEmpty)) {
            if (settings.contains(copiedText)) {
              if (callersContext.mounted) {
                showDialog(
                  context: callersContext,
                  builder: (_) => AlertDialog(
                    title: Text('Already exists'),
                    content: Text(
                      'This link already exists. Try adding a different URL.',
                    ),
                  ),
                );
              }
            } else {
              settings.add(copiedText);
              if (callersContext.mounted) {
                showDialog(
                  context: callersContext,
                  builder: (_) => AlertDialog(
                    title: Text('Saved!'),
                    content: Text('Link added successfully!'),
                  ),
                );
                /*
                ScaffoldMessenger.of(callersContext).showSnackBar(
                  const SnackBar(
                    content: Text('Bookmark added successfully!'),
                    duration: Duration(seconds: 3),
                  ),
                );

                 */
              }
            }
          } else {
            if (callersContext.mounted) {
              showDialog(
                context: callersContext,
                builder: (context) => AlertDialog(
                  title: Text('No Text'),
                  content: Text(
                    'The copied URL does not contain any paragraph text. '
                    'Please try a different URL',
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
          }
        } else {
          if (callersContext.mounted) {
            showDialog(
              context: callersContext,
              builder: (context) => AlertDialog(
                title: Text('Invalid URL'),
                content: Text(
                  'Please copy the URL from your browser\'s address bar.',
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
        }
      } catch (e) {
        if (callersContext.mounted) {
          showDialog(
            context: callersContext,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Error'),
                ],
              ),
              content: Text(
                'Connection error or invalid URL.\n'
                'The copied text is "$copiedText".',
                maxLines: 5,
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
      }
    } else {
      AlertDialog(
        title: Text('No copied URL'),
        content: Text('Please copy the URL from your browser\'s address bar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    }
  }
}
