import '../models/models.dart';
import '../services/database_service.dart';

class ReportRepository {
  final DatabaseService _databaseService = DatabaseService();

  // Create report from Report object
  Future<Report> createReport(Report report) async {
    return saveReport(
      report.userId,
      report.testSetId,
      report.totalQuestions,
      report.correctAnswers,
      report.incorrectAnswers,
      report.score,
      report.percentage,
      report.strengths,
      report.areasForImprovement,
      report.recommendations,
    );
  }

  // Save report
  Future<Report> saveReport(
    int userId,
    int testSetId,
    int? totalQuestions,
    int? correctAnswers,
    int? incorrectAnswers,
    int? score,
    double? percentage,
    String? strengths,
    String? areasForImprovement,
    String? recommendations
  ) async {
    final now = DateTime.now();

    final results = await _databaseService.query(
      '''
      INSERT INTO reports (
        user_id, test_set_id, total_questions, correct_answers, incorrect_answers,
        score, percentage, strengths, areas_for_improvement, recommendations, created_at
      )
      VALUES (
        @userId, @testSetId, @totalQuestions, @correctAnswers, @incorrectAnswers,
        @score, @percentage, @strengths, @areasForImprovement, @recommendations, @createdAt
      )
      RETURNING id
      ''',
      parameters: {
        'userId': userId,
        'testSetId': testSetId,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'incorrectAnswers': incorrectAnswers,
        'score': score,
        'percentage': percentage,
        'strengths': strengths,
        'areasForImprovement': areasForImprovement,
        'recommendations': recommendations,
        'createdAt': now.toIso8601String(),
      },
    );

    final id = results.first['id'] as int;

    return Report(
      id: id,
      userId: userId,
      testSetId: testSetId,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      incorrectAnswers: incorrectAnswers,
      score: score,
      percentage: percentage,
      strengths: strengths,
      areasForImprovement: areasForImprovement,
      recommendations: recommendations,
      createdAt: now,
    );
  }

  // Get reports for a user
  Future<List<Report>> getReportsForUser(int userId) async {
    final results = await _databaseService.query(
      'SELECT * FROM reports WHERE user_id = @userId ORDER BY created_at DESC',
      parameters: {'userId': userId},
    );

    return results.map((row) => Report.fromMap(row)).toList();
  }

  // Alias for getReportsForUser for consistency with other repositories
  Future<List<Report>> getReportsByUser(int userId) async {
    return getReportsForUser(userId);
  }

  // Get reports for a test set
  Future<List<Report>> getReportsForTestSet(int testSetId) async {
    final results = await _databaseService.query(
      'SELECT * FROM reports WHERE test_set_id = @testSetId ORDER BY created_at DESC',
      parameters: {'testSetId': testSetId},
    );

    return results.map((row) => Report.fromMap(row)).toList();
  }

  // Get report by ID
  Future<Report?> getReportById(int id) async {
    final results = await _databaseService.query(
      'SELECT * FROM reports WHERE id = @id',
      parameters: {'id': id},
    );

    if (results.isEmpty) {
      return null;
    }

    return Report.fromMap(results.first);
  }

  // Update report
  Future<Report> updateReport(Report report) async {
    await _databaseService.execute(
      '''
      UPDATE reports
      SET total_questions = @totalQuestions, correct_answers = @correctAnswers, incorrect_answers = @incorrectAnswers,
          score = @score, percentage = @percentage, strengths = @strengths,
          areas_for_improvement = @areasForImprovement, recommendations = @recommendations
      WHERE id = @id
      ''',
      parameters: {
        'id': report.id,
        'totalQuestions': report.totalQuestions,
        'correctAnswers': report.correctAnswers,
        'incorrectAnswers': report.incorrectAnswers,
        'score': report.score,
        'percentage': report.percentage,
        'strengths': report.strengths,
        'areasForImprovement': report.areasForImprovement,
        'recommendations': report.recommendations,
      },
    );

    return report;
  }

  // Delete report
  Future<void> deleteReport(int id) async {
    await _databaseService.execute(
      'DELETE FROM reports WHERE id = @id',
      parameters: {'id': id},
    );
  }
}
