/*
 * word_list_notifier.dart
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
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

enum ActivityViewMode { daily, weekly, monthly }

class WordListNotifier extends ChangeNotifier {
  bool _isLoading = false;

  // For database operations
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Map<String, dynamic>> _wordLog = List.empty(growable: true);
  Map<String, int> _wordCounts = {};
  ActivityViewMode _viewMode = ActivityViewMode.daily;

  WordListNotifier() {
    fetchLog();
  }

  bool get isLoading => _isLoading;

  ActivityViewMode get viewMode => _viewMode;

  set viewMode(ActivityViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  List<Map<String, dynamic>> get wordLog => _wordLog;

  Map<String, int> get wordCounts => _wordCounts;

  Future<void> fetchLog() async {
    _isLoading = true;
    notifyListeners();

    final log = await _db.getAllEntries();
    _wordLog = List<Map<String, dynamic>>.from(log);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWord(String word) async {
    final timestamp = DateTime.now().toIso8601String();
    await _db.addEntry(word);

    _wordLog.insert(0, {'word': word, 'timestamp': timestamp});
    if (_wordLog.length > 10000) _wordLog.removeLast();

    final lowerWord = word.toLowerCase();
    if (_wordCounts.containsKey(lowerWord)) {
      _wordCounts[lowerWord] = _wordCounts[lowerWord]! + 1;
    } else if (_viewMode == ActivityViewMode.weekly) {
      _wordCounts[lowerWord] = 1;
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> extractLogForDuration(
    DateTime date,
    int duration,
  ) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: duration));
    return _wordLog.where((log) {
      final logDate = DateTime.parse(log['timestamp'] as String);
      return logDate.isAfter(startOfDay) && logDate.isBefore(endOfDay);
    }).toList();
  }

  List<MapEntry<String, int>> getWordCountsForDuration(
    DateTime date,
    int duration,
  ) {
    final studyLog = extractLogForDuration(date, duration);
    final result = <String, int>{};
    for (var log in studyLog) {
      final word = log['word'] as String;
      result[word] = (result[word] ?? 0) + 1;
    }
    List<MapEntry<String, int>> temp = result.entries.toList();
    temp.sort((a, b) => b.value.compareTo(a.value));
    return temp;
  }

  int getDailyWordCount(DateTime date) => extractLogForDuration(date, 1).length;

  int getWeeklyWordCount(DateTime date) =>
      extractLogForDuration(date, 7).length;

  List<int> getHalfHourlyCountsPerDay(DateTime date) {
    final studyLog = extractLogForDuration(date, 1);
    final result = List<int>.filled(48, 0);
    for (var log in studyLog) {
      final logDate = DateTime.parse(log['timestamp'] as String);
      final hour = logDate.hour;
      final minute = logDate.minute;
      result[hour * 2 + (minute >= 30 ? 1 : 0)] += 1;
    }
    return result;
  }

  List<int> getDailyCountsPerList(DateTime date) {
    final studyLog = extractLogForDuration(date, 7);
    final result = List<int>.filled(7, 0);
    for (var log in studyLog) {
      final logDate = DateTime.parse(log['timestamp'] as String);
      final weekday = logDate.weekday - 1;
      result[weekday] += 1;
    }
    return result;
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fillblank.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word TEXT NOT NULL,
          timestamp TEXT NOT NULL
        )
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<void> addEntry(String word) async {
    final db = await database;
    await db.insert('logs', {
      'word': word,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Optional: Auto-trim database size
    await db.execute(
      'DELETE FROM logs WHERE id <= (SELECT id FROM logs ORDER BY id DESC LIMIT 1 OFFSET 10000)',
    );
  }

  Future<List<Map<String, dynamic>>> getAllEntries() async {
    final db = await database;
    // Fetch newest 100 first
    return await db.query('logs', orderBy: 'id DESC', limit: 10000);
  }

  Future<List<Map<String, dynamic>>> getEntries(
    DateTime date,
    int duration,
  ) async {
    final db = await database;
    final startOfDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).add(Duration(days: duration)).toIso8601String();
    return await db.query(
      'logs',
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [startOfDay, endOfDay],
      orderBy: 'timestamp ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getWholeSummaryList() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT LOWER(word) as word, COUNT(*) as count 
      FROM logs 
      GROUP BY LOWER(word) 
      ORDER BY count DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getSummaryList(
    DateTime date,
    int duration,
  ) async {
    final db = await database;
    final startOfDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).add(Duration(days: duration)).toIso8601String();
    return await db.rawQuery(
      '''
      SELECT LOWER(word) as word, COUNT(*) as count 
      FROM logs 
      WHERE timestamp >= ? AND timestamp < ?
      GROUP BY LOWER(word) 
      ORDER BY count DESC
    ''',
      [startOfDay, endOfDay],
    );
  }
}
