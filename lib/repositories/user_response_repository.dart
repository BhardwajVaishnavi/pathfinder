import '../models/models.dart';
import '../services/database_service.dart';

class UserResponseRepository {
  final DatabaseService _databaseService = DatabaseService();

  // Create user response from UserResponse object
  Future<UserResponse> createUserResponse(UserResponse userResponse) async {
    return saveUserResponse(
      userResponse.userId,
      userResponse.questionId,
      userResponse.selectedOption,
      userResponse.isCorrect,
      userResponse.responseTime,
    );
  }

  // Save user response
  Future<UserResponse> saveUserResponse(int userId, int questionId, String? selectedOption, bool? isCorrect, int? responseTime) async {
    final now = DateTime.now();

    final results = await _databaseService.query(
      '''
      INSERT INTO user_responses (user_id, question_id, selected_option, is_correct, response_time, created_at)
      VALUES (@userId, @questionId, @selectedOption, @isCorrect, @responseTime, @createdAt)
      RETURNING id
      ''',
      parameters: {
        'userId': userId,
        'questionId': questionId,
        'selectedOption': selectedOption,
        'isCorrect': isCorrect != null ? (isCorrect ? 1 : 0) : null,
        'responseTime': responseTime,
        'createdAt': now.toIso8601String(),
      },
    );

    final id = results.first['id'] as int;

    return UserResponse(
      id: id,
      userId: userId,
      questionId: questionId,
      selectedOption: selectedOption,
      isCorrect: isCorrect,
      responseTime: responseTime,
      createdAt: now,
    );
  }

  // Get user responses for a user
  Future<List<UserResponse>> getUserResponsesForUser(int userId) async {
    final results = await _databaseService.query(
      'SELECT * FROM user_responses WHERE user_id = @userId',
      parameters: {'userId': userId},
    );

    return results.map((row) => UserResponse.fromMap(row)).toList();
  }

  // Get user responses for a question
  Future<List<UserResponse>> getUserResponsesForQuestion(int questionId) async {
    final results = await _databaseService.query(
      'SELECT * FROM user_responses WHERE question_id = @questionId',
      parameters: {'questionId': questionId},
    );

    return results.map((row) => UserResponse.fromMap(row)).toList();
  }

  // Get user response by ID
  Future<UserResponse?> getUserResponseById(int id) async {
    final results = await _databaseService.query(
      'SELECT * FROM user_responses WHERE id = @id',
      parameters: {'id': id},
    );

    if (results.isEmpty) {
      return null;
    }

    return UserResponse.fromMap(results.first);
  }

  // Update user response
  Future<UserResponse> updateUserResponse(UserResponse userResponse) async {
    await _databaseService.execute(
      '''
      UPDATE user_responses
      SET selected_option = @selectedOption, is_correct = @isCorrect, response_time = @responseTime
      WHERE id = @id
      ''',
      parameters: {
        'id': userResponse.id,
        'selectedOption': userResponse.selectedOption,
        'isCorrect': userResponse.isCorrect != null ? (userResponse.isCorrect! ? 1 : 0) : null,
        'responseTime': userResponse.responseTime,
      },
    );

    return userResponse;
  }

  // Delete user response
  Future<void> deleteUserResponse(int id) async {
    await _databaseService.execute(
      'DELETE FROM user_responses WHERE id = @id',
      parameters: {'id': id},
    );
  }

  // Get user responses for a test set
  Future<List<UserResponse>> getUserResponsesByTestSet(int userId, int testSetId) async {
    final results = await _databaseService.query(
      '''
      SELECT ur.*
      FROM user_responses ur
      JOIN questions q ON ur.question_id = q.id
      WHERE ur.user_id = @userId AND q.test_set_id = @testSetId
      ''',
      parameters: {
        'userId': userId,
        'testSetId': testSetId,
      },
    );

    return results.map((row) => UserResponse.fromMap(row)).toList();
  }
}
