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
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'drawers/bookmark_drawers.dart';
import 'provider/bookmarkedUrlsProvider.dart';
import 'screens/training_page.dart';

const kDefaultBookmarkedUrls = [
  'https://www.google.com',
  'https://www.wikipedia.org',
  'https://www.debian.org',
  'https://hu.wikipedia.org/wiki/Wikip%C3%A9dia',
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final bookmarkedUrls =
      prefs.getStringList('bookmarks') ?? kDefaultBookmarkedUrls;

  runApp(
    ChangeNotifierProvider(
      create: (_) => BookmarkedUrlsProvider(bookmarkedUrls),
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

  Future<List<String>> fetchParagraphs(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the HTML string
      final document = parser.parse(response.body);

      // Query all <p> elements
      final pElements = document.getElementsByTagName('p');

      // Extract the text content from each <p>
      return pElements.map((element) => element.text).toList();
    } else {
      throw Exception('Failed to load page');
    }
  }

  // // Saving
  // void _saveBookmarkedUrl(String url) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setStringList('bookmarks', _bookmarkedUrls as List<String>);
  // }
  //

  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkedUrlsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(provider.currentUrl),
            foregroundColor: Colors.black,
            backgroundColor: Colors.lightGreen,
            automaticallyImplyActions: false,
            actions: [
              if (_selectedIndex == 0)
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                ),
            ],
          ),
          body: FutureBuilder<List<String>>(
            future: fetchParagraphs(provider.currentUrl),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator(
                  strokeWidth: 100,
                  color: Colors.lightGreen,
                  backgroundColor: Colors.white,
                );
              }
              return Center(child: TrainingPage(title: 'Training'));
            },
          ),
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
