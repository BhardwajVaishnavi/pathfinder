import '../models/models.dart';
import '../services/database_service.dart';

class TestSetRepository {
  final DatabaseService _databaseService = DatabaseService();

  // Get all test sets
  Future<List<TestSet>> getAllTestSets() async {
    final results = await _databaseService.query(
      'SELECT * FROM test_sets ORDER BY category_id, id',
    );

    return results.map((row) => TestSet.fromMap(row)).toList();
  }

  // Get test sets by category
  Future<List<TestSet>> getTestSetsByCategory(int categoryId) async {
    final results = await _databaseService.query(
      'SELECT * FROM test_sets WHERE category_id = @categoryId ORDER BY id',
      parameters: {'categoryId': categoryId},
    );

    return results.map((row) => TestSet.fromMap(row)).toList();
  }

  // Get test set by ID
  Future<TestSet?> getTestSetById(int id) async {
    final results = await _databaseService.query(
      'SELECT * FROM test_sets WHERE id = @id',
      parameters: {'id': id},
    );

    if (results.isEmpty) {
      return null;
    }

    return TestSet.fromMap(results.first);
  }

  // Get random test set for category
  Future<TestSet?> getRandomTestSetForCategory(int categoryId) async {
    final results = await _databaseService.query(
      'SELECT * FROM test_sets WHERE category_id = @categoryId ORDER BY RANDOM() LIMIT 1',
      parameters: {'categoryId': categoryId},
    );

    if (results.isEmpty) {
      return null;
    }

    return TestSet.fromMap(results.first);
  }

  // Create test set
  Future<TestSet> createTestSet(int categoryId, String title, String? description, int? timeLimit, int? passingScore) async {
    final results = await _databaseService.query(
      '''
      INSERT INTO test_sets (category_id, title, description, time_limit, passing_score)
      VALUES (@categoryId, @title, @description, @timeLimit, @passingScore)
      RETURNING id
      ''',
      parameters: {
        'categoryId': categoryId,
        'title': title,
        'description': description,
        'timeLimit': timeLimit,
        'passingScore': passingScore,
      },
    );

    final id = results.first['id'] as int;

    return TestSet(
      id: id,
      categoryId: categoryId,
      title: title,
      description: description,
      timeLimit: timeLimit,
      passingScore: passingScore,
    );
  }

  // Update test set
  Future<TestSet> updateTestSet(TestSet testSet) async {
    await _databaseService.execute(
      '''
      UPDATE test_sets
      SET category_id = @categoryId, title = @title, description = @description,
          time_limit = @timeLimit, passing_score = @passingScore
      WHERE id = @id
      ''',
      parameters: {
        'id': testSet.id,
        'categoryId': testSet.categoryId,
        'title': testSet.title,
        'description': testSet.description,
        'timeLimit': testSet.timeLimit,
        'passingScore': testSet.passingScore,
      },
    );

    return testSet;
  }

  // Delete test set
  Future<void> deleteTestSet(int id) async {
    await _databaseService.execute(
      'DELETE FROM test_sets WHERE id = @id',
      parameters: {'id': id},
    );
  }
}
