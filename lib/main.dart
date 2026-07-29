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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:readblank/screens/studylog_page.dart';

import 'db/word_list_provider.dart';
import 'drawers/content_selector_drawers.dart';
import 'provider/bookmark_provider.dart';
import 'provider/history_provider.dart';
import 'screens/training_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HistoryProvider(prefs)),
        ChangeNotifierProxyProvider<HistoryProvider, BookmarkProvider>(
          create: (_) => BookmarkProvider(prefs),
          update: (_, historyProvider, bookmarkProvider) {
            return (bookmarkProvider!..update(historyProvider));
          },
        ),
        ChangeNotifierProvider(create: (_) => WordListProvider(prefs)),
      ],
      child: ReadBlank(),
    ),
  );
}

class ReadBlank extends StatelessWidget {
  const ReadBlank({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReadBlank',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightGreen,
        ).copyWith(surface: Colors.white),
      ),
      home: const MainPage(title: 'ReadBlank'),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().fetchAllUrls();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();

    if (provider.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 5,
            color: Colors.lightGreen,
            backgroundColor: Colors.white,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _selectedIndex == 2
          ? AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Study Log', style: TextStyle(color: Colors.black87)),
                ],
              ),
              foregroundColor: Colors.black,
              backgroundColor: Colors.lightGreen,
              automaticallyImplyActions: false,
              actions: [
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.view_list_outlined),
                    onPressed: () {},
                  ),
                ),
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.view_week_outlined),
                    onPressed: () {},
                  ),
                ),
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.calendar_view_month_outlined),
                    onPressed: () {},
                  ),
                ),
              ],
            )
          : AppBar(
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
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.add_link_outlined),
                    onPressed: _addBookmark,
                  ),
                ),
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.list_outlined),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                ),
              ],
            ),
      body: _selectedIndex == 2
          ? StudyLogPage(title: 'Study Log')
          : TrainingPage(title: 'Training'),
      endDrawer: const ContentSelectorDrawers(),
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
            label: 'Library',
            icon: Icon(Icons.library_books_outlined),
          ),
          const NavigationDestination(
            label: 'Log',
            icon: Icon(Icons.bar_chart),
          ),
        ],
      ),
    );
  }

  void _addBookmark() async {
    final callersContext = context;
    final historyProvider = callersContext.read<HistoryProvider>();
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String? copiedText = data?.text;
    if (copiedText != null && copiedText.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(copiedText));
        if (response.statusCode == 200) {
          final document = parser.parse(response.body);
          final pElements = document.getElementsByTagName('p');
          if (pElements.any((element) => element.text.trim().isNotEmpty)) {
            if (historyProvider.contains(copiedText)) {
              if (callersContext.mounted) {
                showDialog(
                  context: callersContext,
                  builder: (BuildContext callersContext) => AlertDialog(
                    title: Text('Already exists'),
                    content: Text(
                      'This link already exists. Do you want to select the link?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          historyProvider.select(copiedText);
                        },
                        child: const Text('Open'),
                      ),
                    ],
                  ),
                );
              }
            } else {
              historyProvider.add(copiedText);
              if (callersContext.mounted) {
                ScaffoldMessenger.of(callersContext).showSnackBar(
                  const SnackBar(
                    content: Text('Link added successfully!'),
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
