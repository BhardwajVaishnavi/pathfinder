import 'init_database.dart' as init_database;
import 'insert_sample_questions.dart' as insert_sample_questions;

/// This script runs both database initialization scripts.
Future<void> main() async {
  print('Setting up database...');
  
  // Initialize database schema
  await init_database.main();
  
  // Insert sample questions
  await insert_sample_questions.main();
  
  print('Database setup completed successfully');
}
