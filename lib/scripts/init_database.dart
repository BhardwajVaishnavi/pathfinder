import 'package:postgres/postgres.dart';
import '../config/database_config.dart';

/// This script initializes the comprehensive database schema for PathfinderAI.
/// Run this script once to set up all database tables.
Future<void> main() async {
  print('Initializing PathfinderAI database schema...');

  final connection = PostgreSQLConnection(
    DatabaseConfig.host,
    DatabaseConfig.port,
    DatabaseConfig.database,
    username: DatabaseConfig.username,
    password: DatabaseConfig.password,
    useSSL: DatabaseConfig.useSSL,
  );

  try {
    await connection.open();
    print('Connected to PostgreSQL database');

    // Create users table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        date_of_birth DATE,
        gender TEXT,
        address TEXT,
        city TEXT,
        state TEXT,
        country TEXT,
        pincode TEXT,
        created_at TIMESTAMP
      )
    ''');
    print('Created users table');

    // Create categories table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT
      )
    ''');

    // Create education_levels table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS education_levels (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        created_at TIMESTAMP
      )
    ''');
    print('Created education_levels table');

    // Create test_sets table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS test_sets (
        id INTEGER PRIMARY KEY,
        category_id INTEGER,
        title TEXT NOT NULL,
        description TEXT,
        time_limit INTEGER,
        passing_score INTEGER
      )
    ''');
    print('Created test_sets table');

    // Create questions table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS questions (
        id INTEGER PRIMARY KEY,
        test_set_id INTEGER NOT NULL,
        question_text TEXT NOT NULL,
        option_a TEXT,
        option_b TEXT,
        option_c TEXT,
        option_d TEXT,
        correct_option CHARACTER(1),
        explanation TEXT
      )
    ''');
    print('Created questions table');

    // Create user_responses table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS user_responses (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,
        selected_option CHARACTER(1),
        is_correct BOOLEAN,
        response_time INTEGER,
        created_at TIMESTAMP
      )
    ''');
    print('Created user_responses table');

    // Create reports table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS reports (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        test_set_id INTEGER NOT NULL,
        total_questions INTEGER,
        correct_answers INTEGER,
        incorrect_answers INTEGER,
        score INTEGER,
        percentage NUMERIC,
        strengths TEXT,
        areas_for_improvement TEXT,
        recommendations TEXT,
        created_at TIMESTAMP
      )
    ''');
    print('Created test_results table');

    // Insert categories
    await connection.execute('''
      INSERT INTO categories (id, name, description, icon)
      VALUES
        (1, '10th Fail', 'Tests for students who have not passed 10th grade', 'school'),
        (2, '10th Pass', 'Tests for students who have passed 10th grade', 'school'),
        (3, '12th Fail', 'Tests for students who have not passed 12th grade', 'school'),
        (4, '12th Pass', 'Tests for students who have passed 12th grade', 'school'),
        (5, 'Graduate (Science)', 'Tests for science graduates', 'science'),
        (6, 'Graduate (Commerce)', 'Tests for commerce graduates', 'business'),
        (7, 'Graduate (Arts)', 'Tests for arts graduates', 'brush'),
        (8, 'Graduate (BTech)', 'Tests for BTech graduates', 'engineering'),
        (9, 'Postgraduate', 'Tests for postgraduates', 'school')
      ON CONFLICT (id) DO NOTHING
    ''');
    print('Inserted categories');

    // Insert education levels
    await connection.execute('''
      INSERT INTO education_levels (id, name, description)
      VALUES
        ('tenth_fail', '10th Fail', 'Students who have not passed 10th grade'),
        ('tenth_pass', '10th Pass', 'Students who have passed 10th grade'),
        ('twelfth_fail', '12th Fail', 'Students who have not passed 12th grade'),
        ('twelfth_pass', '12th Pass', 'Students who have passed 12th grade'),
        ('graduate_science', 'Graduate (Science)', 'Students with a science degree'),
        ('graduate_commerce', 'Graduate (Commerce)', 'Students with a commerce degree'),
        ('graduate_arts', 'Graduate (Arts)', 'Students with an arts degree'),
        ('graduate_btech', 'Graduate (BTech)', 'Students with a BTech degree'),
        ('postgraduate', 'Postgraduate', 'Students with a postgraduate degree')
      ON CONFLICT (id) DO NOTHING
    ''');
    print('Inserted education levels');

    // Insert sample test sets (one for each category)
    for (var i = 1; i <= 4; i++) {
      final setId = (i - 1) * 9 + 1;

      await connection.execute('''
        INSERT INTO test_sets (id, category_id, title, description, time_limit, passing_score)
        VALUES
          ($setId, 1, '10th Fail Aptitude Test - Set $i', 'Aptitude test for students who have not passed 10th grade', 60, 70)
        ON CONFLICT (id) DO NOTHING
      ''');

      await connection.execute('''
        INSERT INTO test_sets (id, category_id, title, description, time_limit, passing_score)
        VALUES
          (${setId + 1}, 2, '10th Pass Aptitude Test - Set $i', 'Aptitude test for students who have passed 10th grade', 60, 70)
        ON CONFLICT (id) DO NOTHING
      ''');

      await connection.execute('''
        INSERT INTO test_sets (id, category_id, title, description, time_limit, passing_score)
        VALUES
          (${setId + 2}, 3, '12th Fail Aptitude Test - Set $i', 'Aptitude test for students who have not passed 12th grade', 60, 70)
        ON CONFLICT (id) DO NOTHING
      ''');

      await connection.execute('''
        INSERT INTO test_sets (id, category_id, title, description, time_limit, passing_score)
        VALUES
          (${setId + 3}, 4, '12th Pass Aptitude Test - Set $i', 'Aptitude test for students who have passed 12th grade', 60, 70)
        ON CONFLICT (id) DO NOTHING
      ''');

      await connection.execute('''
        INSERT INTO test_sets (id, category_id, title, description, time_limit, passing_score)
        VALUES
          (${setId + 4}, 5, 'Science Graduate Aptitude Test - Set $i', 'Aptitude test for science graduates', 60, 70)
        ON CONFLICT (id) DO NOTHING
      ''');

      await connection.execute('''
        INSERT INTO test_sets (id, category_id, title, description, time_limit, passing_score)
        VALUES
          (${setId + 5}, 6, 'Commerce Graduate Aptitude Test - Set $i', 'Aptitude test for commerce graduates', 60, 70)
        ON CONFLICT (id) DO NOTHING
      ''');

      await connection.execute('''
        INSERT INTO test_sets (id, category_id, title, description, time_limit, passing_score)
        VALUES
          (${setId + 6}, 7, 'Arts Graduate Aptitude Test - Set $i', 'Aptitude test for arts graduates', 60, 70)
        ON CONFLICT (id) DO NOTHING
      ''');

      await connection.execute('''
        INSERT INTO test_sets (id, category_id, title, description, time_limit, passing_score)
        VALUES
          (${setId + 7}, 8, 'BTech Graduate Aptitude Test - Set $i', 'Aptitude test for BTech graduates', 60, 70)
        ON CONFLICT (id) DO NOTHING
      ''');

      await connection.execute('''
        INSERT INTO test_sets (id, category_id, title, description, time_limit, passing_score)
        VALUES
          (${setId + 8}, 9, 'Postgraduate Aptitude Test - Set $i', 'Aptitude test for postgraduates', 60, 70)
        ON CONFLICT (id) DO NOTHING
      ''');
    }
    print('Inserted sample test sets');

    print('Database initialization completed successfully');
  } catch (e) {
    print('Error initializing database: $e');
  } finally {
    await connection.close();
    print('Disconnected from PostgreSQL database');
  }
}
