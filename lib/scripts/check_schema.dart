import 'package:postgres/postgres.dart';
import '../config/database_config.dart';

/// This script checks the database schema.
Future<void> main() async {
  print('Checking database schema...');
  
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
    
    // Get all tables
    final tables = await connection.mappedResultsQuery(
      '''
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
      ''',
    );
    
    print('Tables:');
    for (var row in tables) {
      final tableName = row.values.first['table_name'];
      print('- $tableName');
      
      // Get columns for this table
      final columns = await connection.mappedResultsQuery(
        '''
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = @tableName
        ''',
        substitutionValues: {'tableName': tableName},
      );
      
      print('  Columns:');
      for (var column in columns) {
        final columnName = column.values.first['column_name'];
        final dataType = column.values.first['data_type'];
        print('  - $columnName ($dataType)');
      }
      
      print('');
    }
  } catch (e) {
    print('Error checking database schema: $e');
  } finally {
    await connection.close();
    print('Disconnected from PostgreSQL database');
  }
}
