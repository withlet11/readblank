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

enum StudyLogViewMode { list, summary, calendar }

class WordListNotifier extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // For database operations
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Map<String, dynamic>> _studyLog = List.empty(growable: true);
  Map<String, int> _wordCounts = {};
  StudyLogViewMode _viewMode = StudyLogViewMode.list;

  WordListNotifier() {
    loadLogs();
  }

  // For database operations
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> get studyLog => _studyLog;

  Map<String, int> get wordCounts => _wordCounts;

  StudyLogViewMode get viewMode => _viewMode;

  void setViewMode(StudyLogViewMode mode) {
    _viewMode = mode;
    if (mode == StudyLogViewMode.summary) {
      loadWordCounts();
    } else {
      notifyListeners();
    }
  }

  Future<void> loadLogs() async {
    _isLoading = true;
    notifyListeners();

    // Fetch from database
    final logs = await _db.getAllLogs();
    _studyLog = List<Map<String, dynamic>>.from(logs);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadWordCounts() async {
    _isLoading = true;
    notifyListeners();

    final counts = await _db.getWordCounts();
    _wordCounts = {
      for (var item in counts) item['word'] as String: item['count'] as int,
    };

    _isLoading = false;
    notifyListeners();
  }

  int getDayWordCount(DateTime date) => getDayStudyLog(date).length;

  List<Map<String, dynamic>> getDayStudyLog(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _studyLog.where((log) {
      final logDate = DateTime.parse(log['timestamp'] as String);
      return logDate.isAfter(startOfDay) && logDate.isBefore(endOfDay);
    }).toList();
  }

  List<int> getHalfHourlyCountList(DateTime date) {
    final studyLog = getDayStudyLog(date);
    final result = List<int>.filled(48, 0);
    for (var log in studyLog) {
      final logDate = DateTime.parse(log['timestamp'] as String);
      final hour = logDate.hour;
      final minute = logDate.minute;
      result[hour * 2 + (minute >= 30 ? 1 : 0)] += 1;
    }
    return result;
  }

  Future<void> addLog(String word) async {
    final timestamp = DateTime.now().toIso8601String();
    await _db.addLog(word);

    _studyLog.insert(0, {'word': word, 'timestamp': timestamp});
    if (_studyLog.length > 10000) _studyLog.removeLast();

    // Update wordCounts if it's already loaded or we are in summary mode
    final lowerWord = word.toLowerCase();
    if (_wordCounts.containsKey(lowerWord)) {
      _wordCounts[lowerWord] = _wordCounts[lowerWord]! + 1;
    } else if (_viewMode == StudyLogViewMode.summary) {
      _wordCounts[lowerWord] = 1;
    }

    notifyListeners();
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

  Future<void> addLog(String word) async {
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

  Future<List<Map<String, dynamic>>> getAllLogs() async {
    final db = await database;
    // Fetch newest 100 first
    return await db.query('logs', orderBy: 'id DESC', limit: 10000);
  }

  Future<List<Map<String, dynamic>>> getWordCounts() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT LOWER(word) as word, COUNT(*) as count 
      FROM logs 
      GROUP BY LOWER(word) 
      ORDER BY count DESC
    ''');
  }
}
