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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:readblank/screens/studylog_page.dart';

import 'db/word_list_provider.dart';
import 'drawers/bookmark_drawers.dart';
import 'provider/bookmarked_urls_provider.dart';
import 'provider/history_provider.dart';
import 'screens/training_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookmarkedUrlsProvider(prefs)),
        ChangeNotifierProvider(create: (_) => HistoryProvider(prefs)),
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
}
