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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/word_list_provider.dart';

class StudyLogPage extends StatefulWidget {
  final String title;

  const StudyLogPage({super.key, required this.title});

  @override
  State<StudyLogPage> createState() => _StudyLogPageState();
}

class _StudyLogPageState extends State<StudyLogPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WordListProvider>(
      builder: (context, provider, child) {
        return Center(
          child: ListView.builder(
            itemCount: provider.studyLog.length,
            itemBuilder: (context, index) {
              final logItem = provider.studyLog[index];
              final word = logItem['word'] ?? 'No title';
              final timestamp = logItem['timestamp'] ?? '';
              return Container(
                height: 48,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      word, // provider.studyLog[index].split(',')[1],
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      DateFormat.yMd().add_jm().format(
                        DateTime.parse(timestamp),
                        /*
                    DateTime.parse(
                      provider.studyLog[index].split(',')[0],
                    ).toLocal(),
                     */
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
    );
  }
}
