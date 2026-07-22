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

import '../provider/bookmarked_urls_provider.dart';

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
          child: ListView.builder(
            itemCount: provider.bookmarkList.length,
            itemBuilder: (context, index) {
              final (onPressed, iconColor) = provider.bookmarkList.length > 1
                  ? (
                      () {
                        setState(() {
                          provider.removeBookmark(index);
                        });
                      },
                      Colors.red,
                    )
                  : (null, Colors.grey);
              return ListTile(
                selected: provider.isSelectedBookmark(
                  provider.bookmarkList[index],
                ),
                selectedTileColor: Colors.lightGreen.shade200,
                title: Text(provider.bookmarkList[index]),
                onTap: () {
                  setState(() {
                    provider.selectBookmark(provider.bookmarkList[index]);
                  });
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: iconColor),
                  onPressed: onPressed,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
