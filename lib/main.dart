/*
 * main.dart
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

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wl11_fillblank/screens/bookmark_page.dart';

import 'drawers/bookmark_drawers.dart';
import 'provider/bookmarked_urls_provider.dart';
import 'screens/training_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    ChangeNotifierProvider(
      create: (_) => BookmarkedUrlsProvider(prefs),
      child: FillWords(),
    ),
  );
}

class FillWords extends StatelessWidget {
  const FillWords({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightGreen,
        ).copyWith(surface: Colors.white),
      ),
      home: const MainPage(title: 'Fill Words'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _restoreDefaultList() async {
    final settings = context.read<BookmarkedUrlsProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restore Default List'),
        content: Text('Are you sure you want to restore the default list?'),
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
      settings.restoreDefaultList();
    }
  }

  void _addBookmark() async {
    final callersContext = context;
    final settings = callersContext.read<BookmarkedUrlsProvider>();
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String? copiedText = data?.text;
    if (copiedText != null && copiedText.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(copiedText));
        if (response.statusCode == 200) {
          final document = parser.parse(response.body);
          final pElements = document.getElementsByTagName('p');
          if (pElements.any((element) => element.text.trim().isNotEmpty)) {
            if (settings.containsBookmark(copiedText)) {
              if (callersContext.mounted) {
                ScaffoldMessenger.of(callersContext).showSnackBar(
                  const SnackBar(
                    content: Text('Bookmark already exists!'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            } else {
              settings.addBookmark(copiedText);
              if (callersContext.mounted) {
                ScaffoldMessenger.of(callersContext).showSnackBar(
                  const SnackBar(
                    content: Text('Bookmark added successfully!'),
                    duration: Duration(seconds: 3),
                  ),
                );
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
      if (callersContext.mounted) {
        showDialog(
          context: callersContext,
          builder: (context) => AlertDialog(
            title: Text('No copied URL'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkedUrlsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.currentTitle,
                  style: TextStyle(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  provider.currentDomainName,
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            foregroundColor: Colors.black,
            backgroundColor: Colors.lightGreen,
            automaticallyImplyActions: false,
            actions: [
              if (_selectedIndex == 0)
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.bookmarks_outlined),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                ),
              if (_selectedIndex == 1) ...[
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.settings_backup_restore),
                    onPressed: _restoreDefaultList,
                  ),
                ),
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.bookmark_add_outlined),
                    onPressed: _addBookmark,
                  ),
                ),
              ],
            ],
          ),
          body: _selectedIndex == 1
              ? BookmarkPage(title: 'Bookmarks')
              : TrainingPage(title: 'Training'),
          endDrawer: const BookmarkDrawers(),
          bottomNavigationBar: NavigationBar(
            backgroundColor: Colors.white,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: [
              const NavigationDestination(
                label: 'Learn',
                icon: Icon(Icons.edit_note),
              ),
              const NavigationDestination(
                label: 'Bookmarks',
                icon: Icon(Icons.bookmarks),
              ),
              const NavigationDestination(
                label: 'Contact',
                icon: Icon(Icons.contact_support),
              ),
            ],
          ),
        );
      },
    );
  }
}
