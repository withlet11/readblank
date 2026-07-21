/*
 * bookmark_page.dart
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
import 'package:provider/provider.dart';

import '../provider/bookmarkedUrlsProvider.dart';

class BookmarkPage extends StatefulWidget {
  final String title;

  const BookmarkPage({super.key, required this.title});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkedUrlsProvider>(
      builder: (context, provider, child) {
        return Center(
          /*
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: Colors.deepPurple,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_add, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'How to bookmark a URL:',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Copy the URL from your browser\'s address bar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Click the + button located on this screen.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
           */
          child: ListView.builder(
            itemCount: provider.bookmarkedUrls.length,
            itemBuilder: (context, index) {
              final (
                onPressed,
                iconColor,
              ) = (index > 0 || provider.bookmarkedUrls.length > 1)
                  ? (
                      () {
                        setState(() {
                          provider.removeItem(provider.bookmarkedUrls[index]);
                        });
                      },
                      Colors.red,
                    )
                  : (null, Colors.grey);
              return ListTile(
                title: Text(provider.bookmarkedUrls[index]),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: iconColor),
                  onPressed: onPressed,
                ),
              );
            },
            // ),
            // ),
            // ],
          ),
        );
      },
    );
  }
}
