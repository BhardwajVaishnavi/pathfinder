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
