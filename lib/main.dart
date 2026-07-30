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
import 'package:readblank/screens/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:readblank/screens/log_page.dart';

import 'db/word_list_provider.dart';
import 'drawers/content_selector_drawers.dart';
import 'provider/bookmark_provider.dart';
import 'provider/history_provider.dart';
import 'screens/read_page.dart';

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
        ChangeNotifierProvider(create: (_) => WordListProvider()),
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
    final historyProvider = context.watch<HistoryProvider>();
    final wordListProvider = context.watch<WordListProvider>();

    if (historyProvider.isLoading) {
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
      appBar: _selectedIndex == 0
          ? _buildAppBarForRead(historyProvider)
          : _selectedIndex == 1
          ? _buildAppBarForLog(wordListProvider)
          : _buildAppBarForSettings(),
      body: _selectedIndex == 0
          ? ReadPage(key: Key('ReadPage'), title: 'Read')
          : _selectedIndex == 1
          ? LogPage(key: Key('LogPage'), title: 'Log')
          : SettingsPage(key: Key('SettingsPage'), title: 'Settings'),
      endDrawer: const ContentSelectorDrawers(),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  AppBar _buildAppBarForRead(HistoryProvider historyProvider) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            historyProvider.currentTitle,
            style: TextStyle(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            historyProvider.currentDomainName,
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
            onPressed: _addLink,
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
    );
  }

  AppBar _buildAppBarForLog(WordListProvider wordListProvider) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('Log', style: TextStyle(color: Colors.black87))],
      ),
      foregroundColor: Colors.black,
      backgroundColor: Colors.lightGreen,
      automaticallyImplyActions: false,
      actions: [
        IconButton(
          icon: Icon(
            wordListProvider.viewMode == StudyLogViewMode.list
                ? Icons.view_list
                : Icons.view_list_outlined,
          ),
          onPressed: () => wordListProvider.setViewMode(StudyLogViewMode.list),
        ),
        IconButton(
          icon: Icon(
            wordListProvider.viewMode == StudyLogViewMode.summary
                ? Icons.view_week
                : Icons.view_week_outlined,
          ),
          onPressed: () =>
              wordListProvider.setViewMode(StudyLogViewMode.summary),
        ),
        IconButton(
          icon: Icon(Icons.calendar_view_month_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  AppBar _buildAppBarForSettings() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('Settings')],
      ),
      foregroundColor: Colors.black,
      backgroundColor: Colors.lightGreen,
      automaticallyImplyActions: false,
      actions: [],
    );
  }

  NavigationBar _buildNavigationBar() {
    return NavigationBar(
      backgroundColor: Colors.white,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      destinations: [
        const NavigationDestination(
          label: 'Read',
          icon: Icon(Icons.article_outlined),
        ),
        const NavigationDestination(label: 'Log', icon: Icon(Icons.bar_chart)),
        const NavigationDestination(
          label: 'Settings',
          icon: Icon(Icons.settings),
        ),
      ],
    );
  }

  void _addLink() async {
    final historyProvider = context.read<HistoryProvider>();
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
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
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
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Link added successfully!'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            }
          } else {
            if (mounted) {
              showDialog(
                context: context,
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
          if (mounted) {
            showDialog(
              context: context,
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
        if (mounted) {
          showDialog(
            context: context,
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
      if (mounted) {
        showDialog(
          context: context,
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
}
