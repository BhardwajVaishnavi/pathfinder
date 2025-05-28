import '../models/models.dart';
import '../services/database_service.dart';

class QuestionRepository {
  final DatabaseService _databaseService = DatabaseService();

  // Get all questions for a test set
  Future<List<Question>> getQuestionsForTestSet(int testSetId) async {
    final results = await _databaseService.query(
      'SELECT * FROM questions WHERE test_set_id = @testSetId',
      parameters: {'testSetId': testSetId},
    );

    return results.map((row) => Question.fromMap(row)).toList();
  }

  // Alias for getQuestionsForTestSet for consistency with other repositories
  Future<List<Question>> getQuestionsByTestSet(int testSetId) async {
    return getQuestionsForTestSet(testSetId);
  }

  // Get question by ID
  Future<Question?> getQuestionById(int id) async {
    final results = await _databaseService.query(
      'SELECT * FROM questions WHERE id = @id',
      parameters: {'id': id},
    );

    if (results.isEmpty) {
      return null;
    }

    return Question.fromMap(results.first);
  }

  // Create question
  Future<Question> createQuestion(
    int testSetId,
    String questionText,
    String optionA,
    String optionB,
    String optionC,
    String optionD,
    String correctOption,
    String? explanation
  ) async {
    final results = await _databaseService.query(
      '''
      INSERT INTO questions (test_set_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation)
      VALUES (@testSetId, @questionText, @optionA, @optionB, @optionC, @optionD, @correctOption, @explanation)
      RETURNING id
      ''',
      parameters: {
        'testSetId': testSetId,
        'questionText': questionText,
        'optionA': optionA,
        'optionB': optionB,
        'optionC': optionC,
        'optionD': optionD,
        'correctOption': correctOption,
        'explanation': explanation,
      },
    );

    final id = results.first['id'] as int;

    return Question(
      id: id,
      testSetId: testSetId,
      questionText: questionText,
      optionA: optionA,
      optionB: optionB,
      optionC: optionC,
      optionD: optionD,
      correctOption: correctOption,
      explanation: explanation,
    );
  }

  // Update question
  Future<Question> updateQuestion(Question question) async {
    await _databaseService.execute(
      '''
      UPDATE questions
      SET test_set_id = @testSetId, question_text = @questionText,
          option_a = @optionA, option_b = @optionB, option_c = @optionC, option_d = @optionD,
          correct_option = @correctOption, explanation = @explanation
      WHERE id = @id
      ''',
      parameters: {
        'id': question.id,
        'testSetId': question.testSetId,
        'questionText': question.questionText,
        'optionA': question.optionA,
        'optionB': question.optionB,
        'optionC': question.optionC,
        'optionD': question.optionD,
        'correctOption': question.correctOption,
        'explanation': question.explanation,
      },
    );

    return question;
  }

  // Delete question
  Future<void> deleteQuestion(int id) async {
    await _databaseService.execute(
      'DELETE FROM questions WHERE id = @id',
      parameters: {'id': id},
    );
  }
}
