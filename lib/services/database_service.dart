import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:postgres/postgres.dart';
import '../config/database_config.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late PostgreSQLConnection _connection;
  bool _isConnected = false;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> initialize() async {
    try {
      await connect();
      await _createTables();
      print('✅ Database initialized successfully');
    } catch (e) {
      print('❌ Database initialization failed: $e');
      // Continue without database for testing
    }
  }

  Future<void> _createTables() async {
    if (kIsWeb) {
      print('Running on web platform, skipping table creation');
      return;
    }

    try {
      // Create categories table
      await execute('''
        CREATE TABLE IF NOT EXISTS categories (
          id SERIAL PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          description TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Create test_sets table
      await execute('''
        CREATE TABLE IF NOT EXISTS test_sets (
          id SERIAL PRIMARY KEY,
          category_id INTEGER REFERENCES categories(id),
          name VARCHAR(255) NOT NULL,
          description TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Create questions table
      await execute('''
        CREATE TABLE IF NOT EXISTS questions (
          id SERIAL PRIMARY KEY,
          test_set_id INTEGER REFERENCES test_sets(id),
          question_text TEXT NOT NULL,
          option_a TEXT NOT NULL,
          option_b TEXT NOT NULL,
          option_c TEXT NOT NULL,
          option_d TEXT NOT NULL,
          correct_answer CHAR(1) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Create users table
      await execute('''
        CREATE TABLE IF NOT EXISTS users (
          id SERIAL PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          email VARCHAR(255) UNIQUE,
          phone VARCHAR(20),
          date_of_birth DATE,
          gender VARCHAR(10),
          address TEXT,
          city VARCHAR(100),
          state VARCHAR(100),
          country VARCHAR(100),
          pincode VARCHAR(10),
          education_category VARCHAR(100),
          institution_name VARCHAR(255),
          academic_year VARCHAR(20),
          parent_contact VARCHAR(20),
          preferred_language VARCHAR(50),
          identity_proof_type VARCHAR(100),
          identity_proof_number VARCHAR(100),
          identity_proof_image_path TEXT,
          password_hash VARCHAR(255),
          is_profile_complete BOOLEAN DEFAULT FALSE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Create user_responses table
      await execute('''
        CREATE TABLE IF NOT EXISTS user_responses (
          id SERIAL PRIMARY KEY,
          user_id INTEGER NOT NULL,
          question_id INTEGER NOT NULL,
          selected_option VARCHAR(10),
          is_correct BOOLEAN,
          response_time INTEGER,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Create reports table
      await execute('''
        CREATE TABLE IF NOT EXISTS reports (
          id SERIAL PRIMARY KEY,
          user_id INTEGER NOT NULL,
          test_set_id INTEGER NOT NULL,
          total_questions INTEGER NOT NULL,
          correct_answers INTEGER NOT NULL,
          incorrect_answers INTEGER NOT NULL,
          score INTEGER NOT NULL,
          percentage DECIMAL(5,2) NOT NULL,
          strengths TEXT,
          areas_for_improvement TEXT,
          recommendations TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      print('✅ Database tables created successfully');
    } catch (e) {
      print('❌ Error creating tables: $e');
      // Don't rethrow - continue without database
    }
  }

  Future<void> connect() async {
    if (_isConnected) return;

    // Skip actual connection on web platform
    if (kIsWeb) {
      print('Running on web platform, skipping PostgreSQL connection');
      _isConnected = true;
      return;
    }

    _connection = PostgreSQLConnection(
      DatabaseConfig.host,
      DatabaseConfig.port,
      DatabaseConfig.database,
      username: DatabaseConfig.username,
      password: DatabaseConfig.password,
      useSSL: DatabaseConfig.useSSL,
    );

    try {
      await _connection.open();
      _isConnected = true;
      print('Connected to PostgreSQL database');
    } catch (e) {
      print('Error connecting to PostgreSQL database: $e');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (!_isConnected) return;

    await _connection.close();
    _isConnected = false;
    print('Disconnected from PostgreSQL database');
  }

  Future<List<Map<String, dynamic>>> query(String sql, {Map<String, dynamic>? parameters}) async {
    if (!_isConnected) {
      await connect();
    }

    // Return mock data on web platform
    if (kIsWeb) {
      print('Running on web platform, returning mock data for query: $sql');
      return [];
    }

    try {
      final results = await _connection.mappedResultsQuery(
        sql,
        substitutionValues: parameters,
      );

      // Convert the results to a list of maps
      return results.map((row) {
        // Each row has a map with table name as key and column values as value
        // We flatten this to a single map
        final flattenedRow = <String, dynamic>{};
        row.forEach((tableName, tableData) {
          tableData.forEach((column, value) {
            flattenedRow[column] = value;
          });
        });
        return flattenedRow;
      }).toList();
    } catch (e) {
      print('Error executing query: $e');
      rethrow;
    }
  }

  Future<int> execute(String sql, {Map<String, dynamic>? parameters}) async {
    if (!_isConnected) {
      await connect();
    }

    // Return mock data on web platform
    if (kIsWeb) {
      print('Running on web platform, returning mock data for execute: $sql');
      return 1; // Simulate one row affected
    }

    try {
      return await _connection.execute(
        sql,
        substitutionValues: parameters,
      );
    } catch (e) {
      print('Error executing statement: $e');
      rethrow;
    }
  }

  Future<void> transaction(Future<void> Function(PostgreSQLExecutionContext) action) async {
    if (!_isConnected) {
      await connect();
    }

    // Skip transaction on web platform
    if (kIsWeb) {
      print('Running on web platform, skipping transaction');
      return;
    }

    try {
      await _connection.transaction((ctx) async {
        await action(ctx);
      });
    } catch (e) {
      print('Error executing transaction: $e');
      rethrow;
    }
  }
}
