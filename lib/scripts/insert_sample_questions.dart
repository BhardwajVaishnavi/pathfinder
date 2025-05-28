import 'package:postgres/postgres.dart';
import '../config/database_config.dart';

/// This script inserts sample questions for each test set.
/// Run this script after initializing the database.
Future<void> main() async {
  print('Inserting sample questions...');

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

    // Get all test sets
    final testSets = await connection.mappedResultsQuery(
      'SELECT id FROM test_sets',
    );

    int questionId = 1;

    for (var row in testSets) {
      final testSetId = row.values.first['id'];

      // Insert 10 questions for each test set
      for (var i = 1; i <= 10; i++) {
        final correctOption = ['A', 'B', 'C', 'D'][i % 4];

        await connection.execute(
          '''
          INSERT INTO questions (id, test_set_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation)
          VALUES (@id, @testSetId, @questionText, @optionA, @optionB, @optionC, @optionD, @correctOption, @explanation)
          ON CONFLICT (id) DO NOTHING
          ''',
          substitutionValues: {
            'id': questionId++,
            'testSetId': testSetId,
            'questionText': 'Sample question $i for test set $testSetId',
            'optionA': 'Option A',
            'optionB': 'Option B',
            'optionC': 'Option C',
            'optionD': 'Option D',
            'correctOption': correctOption,
            'explanation': 'Explanation for question $i',
          },
        );
      }

      print('Inserted 10 questions for test set $testSetId');
    }

    print('Sample questions insertion completed successfully');
  } catch (e) {
    print('Error inserting sample questions: $e');
  } finally {
    await connection.close();
    print('Disconnected from PostgreSQL database');
  }
}
