import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  static Database? _database;

  factory LocalDatabaseService() {
    return _instance;
  }

  LocalDatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'pathfinder_test_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        education_level TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create test_sets table
    await db.execute('''
      CREATE TABLE test_sets (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        education_level TEXT NOT NULL,
        set_number INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create questions table
    await db.execute('''
      CREATE TABLE questions (
        id TEXT PRIMARY KEY,
        test_set_id TEXT NOT NULL,
        question_text TEXT NOT NULL,
        question_type TEXT NOT NULL,
        options TEXT,
        correct_answer TEXT,
        points INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (test_set_id) REFERENCES test_sets (id) ON DELETE CASCADE
      )
    ''');

    // Create user_responses table
    await db.execute('''
      CREATE TABLE user_responses (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        question_id TEXT NOT NULL,
        test_set_id TEXT NOT NULL,
        response TEXT,
        is_correct INTEGER,
        points_earned INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE,
        FOREIGN KEY (test_set_id) REFERENCES test_sets (id) ON DELETE CASCADE
      )
    ''');

    // Create test_results table
    await db.execute('''
      CREATE TABLE test_results (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        test_set_id TEXT NOT NULL,
        total_points INTEGER NOT NULL,
        points_earned INTEGER NOT NULL,
        percentage REAL NOT NULL,
        completed_at TEXT NOT NULL,
        analysis_data TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (test_set_id) REFERENCES test_sets (id) ON DELETE CASCADE
      )
    ''');
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> update(String table, Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }
}
