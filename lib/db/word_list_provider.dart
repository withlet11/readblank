/*
 * word_db.dart
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
import 'package:shared_preferences/shared_preferences.dart';

class WordListProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _data;
  String? _error;

  final SharedPreferences prefs;

  // For database operations
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Map<String, dynamic>> _studyLog = List.empty(growable: true);

  WordListProvider(this.prefs) {
    final log = prefs.getStringList('studyLog');
    loadLogs();
  }

  // For database operations
  bool get isDbLoading => _isLoading;
  List<Map<String, dynamic>> get studyLog => _studyLog;

  Future<void> loadLogs() async {
    _isLoading = true;
    notifyListeners();

    // Fetch from database
    _studyLog = await _db.getAllLogs();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addLog(String word) async {
    await _db.addLog(word);
    _studyLog.insert(0, {'word': word, 'timestamp': DateTime.now().toIso8601String()});
    if (_studyLog.length > 10000) _studyLog.removeLast();
    notifyListeners();
  }

/*
  void addStudyLog(DateTime dateTime, String word) {
    _wordDb.studyLog.add('${dateTime.toIso8601String()},$word');
    prefs.setStringList('studyLog', _wordDb.studyLog);
    notifyListeners();
  }
   */
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

  /*
  // Insert
  Future<int> addBookmark(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('bookmarks', row);
  }

  // Query
  Future<List<Map<String, dynamic>>> getAllBookmarks() async {
    final db = await instance.database;
    return await db.query('bookmarks');
  }

  // Delete
  Future<int> deleteBookmark(int id) async {
    final db = await instance.database;
    return await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  void saveUrl(String url, String title) async {
    await DatabaseHelper.instance.addBookmark({'url': url, 'title': title});
    print('Saved!');
  }
   */
}
