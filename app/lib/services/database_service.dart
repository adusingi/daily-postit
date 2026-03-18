import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasePath();
    final dir = Directory(dirname(dbPath));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<String> getDatabasePath() async {
    if (Platform.isMacOS) {
      final home = Platform.environment['HOME']!;
      return join(home, 'Library', 'Application Support', 'DailyPostIt', 'tasks.db');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return join(dir.path, 'tasks.db');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        is_done INTEGER DEFAULT 0,
        hidden_text TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_tasks_date ON tasks(date)');
    await db.execute('CREATE INDEX idx_tasks_date_is_done ON tasks(date, is_done)');
  }

  Future<int> createTask(Task task) async {
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

  Future<List<Task>> getTasksForDate(String date) async {
    final db = await instance.database;
    final maps = await db.query(
      'tasks',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getAllTasks() async {
    final db = await instance.database;
    final maps = await db.query(
      'tasks',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<String>> getTaskDatesBefore(String date) async {
    final db = await instance.database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT date FROM tasks WHERE date < ? ORDER BY date DESC',
      [date],
    );

    return maps.map((map) => map['date'] as String).toList();
  }

  Future<Task?> getTaskById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  Future<void> rolloverTasks(String fromDate, String toDate) async {
    final db = await instance.database;
    await db.update(
      'tasks',
      {'date': toDate, 'updated_at': DateTime.now().toIso8601String()},
      where: 'date = ? AND is_done = 0',
      whereArgs: [fromDate],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
