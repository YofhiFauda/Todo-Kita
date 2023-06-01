// lib/service/database_helper.dart

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo_kita/model/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('todo.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        time TEXT,
        color INTEGER,
        isCompleted INTEGER
      )
    ''');
  }

  Future<List<Task>> getTasks() async {
    final db = await instance.database;
    final tasksData = await db.query('tasks');

    return tasksData
        .map((taskData) => Task(
              id: taskData['id'] as int,
              title: taskData['title'] as String,
              description: taskData['description'] as String,
              time: _parseTimeOfDay(
                taskData['hour'] as int?,
                taskData['minute'] as int?,
              ),
              color: Color(taskData['color'] as int),
              isCompleted: taskData['isCompleted'] == 1,
            ))
        .toList();
  }

  TimeOfDay _parseTimeOfDay(int? hour, int? minute) {
    final parsedHour = hour ?? 0;
    final parsedMinute = minute ?? 0;
    return TimeOfDay(hour: parsedHour, minute: parsedMinute);
  }

  Future<int> insertTask(Task task) async {
    final db = await instance.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
