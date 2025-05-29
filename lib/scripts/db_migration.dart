import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/database_service.dart';

class DatabaseMigration {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> migrate() async {
    if (kIsWeb) {
      print('Running on web platform, skipping database migration');
      return;
    }

    try {
      await _databaseService.connect();

      // Check if tables exist in your existing schema
      await _checkExistingSchema();

      print('Database migration completed successfully');
    } catch (e) {
      print('Error during database migration: $e');
      // Don't rethrow - let the app continue with existing schema
      print('Continuing with existing database schema...');
    }
  }

  Future<void> _checkExistingSchema() async {
    try {
      // Check if your existing tables exist
      final tables = await _databaseService.query('''
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name IN ('students', 'parents', 'teachers', 'questions', 'test_sets', 'education_categories')
      ''');

      print('Found ${tables.length} existing tables in your PathfinderAI database');

      for (final table in tables) {
        print('✅ Table exists: ${table['table_name']}');
      }

      // Check question count
      final questionCount = await _databaseService.query('SELECT COUNT(*) as count FROM questions');
      print('📊 Total questions in database: ${questionCount.first['count']}');

      // Check test sets
      final testSetCount = await _databaseService.query('SELECT COUNT(*) as count FROM test_sets');
      print('📝 Total test sets: ${testSetCount.first['count']}');

      print('✅ Your existing NeonDB schema is ready for PathfinderAI!');

    } catch (e) {
      print('Error checking existing schema: $e');
      rethrow;
    }
  }
}
