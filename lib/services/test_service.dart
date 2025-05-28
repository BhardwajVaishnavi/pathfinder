import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/models.dart';
import '../repositories/repositories.dart';
import 'achievement_service.dart';
import 'auth_service.dart';

class TestService {
  static final TestService _instance = TestService._internal();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final TestSetRepository _testSetRepository = TestSetRepository();
  final QuestionRepository _questionRepository = QuestionRepository();
  final UserResponseRepository _userResponseRepository = UserResponseRepository();
  final ReportRepository _reportRepository = ReportRepository();
  final AuthService _authService = AuthService();
  final AchievementService _achievementService = AchievementService();

  factory TestService() {
    return _instance;
  }

  TestService._internal();

  // Get all categories
  Future<List<Category>> getCategories() async {
    try {
      if (kIsWeb) {
        // Return mock data for web
        return [
          Category(id: 1, name: '10th Fail', description: 'Tests for 10th fail students'),
          Category(id: 2, name: '10th Pass', description: 'Tests for 10th pass students'),
          Category(id: 3, name: '12th Fail', description: 'Tests for 12th fail students'),
          Category(id: 4, name: '12th Pass', description: 'Tests for 12th pass students'),
          Category(id: 5, name: 'Graduate (Science)', description: 'Tests for science graduates'),
          Category(id: 6, name: 'Graduate (Commerce)', description: 'Tests for commerce graduates'),
          Category(id: 7, name: 'Graduate (Arts)', description: 'Tests for arts graduates'),
          Category(id: 8, name: 'Graduate (BTech)', description: 'Tests for BTech graduates'),
          Category(id: 9, name: 'Postgraduate', description: 'Tests for postgraduates'),
        ];
      }

      return await _categoryRepository.getAllCategories();
    } catch (e) {
      print('Error getting categories: $e');
      rethrow;
    }
  }

  // Get test sets for a category
  Future<List<TestSet>> getTestSetsForCategory(int categoryId) async {
    try {
      if (kIsWeb) {
        // Return mock data for web
        return List.generate(4, (index) => TestSet(
          id: categoryId * 10 + index + 1,
          categoryId: categoryId,
          title: 'Test Set ${index + 1} for Category $categoryId',
          description: 'This is a test set for category $categoryId',
          timeLimit: 60,
          passingScore: 70,
        ));
      }

      return await _testSetRepository.getTestSetsByCategory(categoryId);
    } catch (e) {
      print('Error getting test sets: $e');
      rethrow;
    }
  }

  // Get questions for a test set
  Future<List<Question>> getQuestionsForTestSet(int testSetId) async {
    try {
      if (kIsWeb) {
        // Return mock data for web
        return List.generate(10, (index) => Question(
          id: testSetId * 100 + index + 1,
          testSetId: testSetId,
          questionText: 'Question ${index + 1} for test set $testSetId',
          optionA: 'Option A',
          optionB: 'Option B',
          optionC: 'Option C',
          optionD: 'Option D',
          correctOption: ['A', 'B', 'C', 'D'][index % 4],
          explanation: 'Explanation for question ${index + 1}',
        ));
      }

      return await _questionRepository.getQuestionsByTestSet(testSetId);
    } catch (e) {
      print('Error getting questions: $e');
      rethrow;
    }
  }

  // Submit test responses and generate report
  Future<Report> submitTest(
    int testSetId,
    List<Question> questions,
    Map<int, String> responses,
    int timeSpentInSeconds,
  ) async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      final userId = _authService.currentUserId!;

      // Calculate score
      int correctAnswers = 0;
      int incorrectAnswers = 0;

      final userResponses = <UserResponse>[];

      for (final question in questions) {
        final selectedOption = responses[question.id];
        final isCorrect = selectedOption == question.correctOption;

        if (isCorrect) {
          correctAnswers++;
        } else {
          incorrectAnswers++;
        }

        userResponses.add(UserResponse(
          id: 0, // Will be assigned by the database
          userId: userId,
          questionId: question.id,
          selectedOption: selectedOption ?? '',
          isCorrect: isCorrect,
          responseTime: timeSpentInSeconds ~/ questions.length, // Approximate time per question
          createdAt: DateTime.now(),
        ));
      }

      final totalQuestions = questions.length;
      final score = (correctAnswers * 100) ~/ totalQuestions;
      final percentage = (correctAnswers * 100.0) / totalQuestions;

      // Generate strengths and areas for improvement
      final strengths = _generateStrengths(questions, userResponses);
      final areasForImprovement = _generateAreasForImprovement(questions, userResponses);
      final recommendations = _generateRecommendations(questions, userResponses, percentage);

      // Create report
      final report = Report(
        id: 0, // Will be assigned by the database
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
        createdAt: DateTime.now(),
      );

      if (kIsWeb) {
        // Skip saving to database on web
        print('Running on web platform, skipping database operations');
        return report;
      }

      // Save user responses
      for (final response in userResponses) {
        await _userResponseRepository.createUserResponse(response);
      }

      // Save report
      final savedReport = await _reportRepository.createReport(report);

      // Check if the test was completed in less than half the allotted time
      final testSet = await _testSetRepository.getTestSetById(testSetId);
      if (testSet != null) {
        final timeLimit = testSet.timeLimit ?? 60; // Default 60 minutes
        final minutesTaken = timeSpentInSeconds / 60; // Convert seconds to minutes

        if (minutesTaken < timeLimit / 2) {
          // Unlock speed demon achievement
          await _achievementService.unlockAchievement('speed_demon');

          // Update quick thinker badge
          await _achievementService.updateBadgeProgress('quick_thinker', 1);
        }
      }

      return savedReport;
    } catch (e) {
      print('Error submitting test: $e');
      rethrow;
    }
  }

  // Get reports for current user
  Future<List<Report>> getUserReports() async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      final userId = _authService.currentUserId!;

      if (kIsWeb) {
        // Return mock data for web
        return [
          Report(
            id: 1,
            userId: userId,
            testSetId: 1,
            totalQuestions: 10,
            correctAnswers: 8,
            incorrectAnswers: 2,
            score: 80,
            percentage: 80.0,
            strengths: 'Strong performance in logical reasoning questions.',
            areasForImprovement: 'Could improve on mathematical problems.',
            recommendations: 'Practice more math problems to improve overall score.',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          Report(
            id: 2,
            userId: userId,
            testSetId: 3,
            totalQuestions: 10,
            correctAnswers: 7,
            incorrectAnswers: 2,
            score: 70,
            percentage: 70.0,
            strengths: 'Good understanding of basic concepts.',
            areasForImprovement: 'Need to work on advanced topics.',
            recommendations: 'Review advanced concepts before taking the next test.',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          Report(
            id: 3,
            userId: userId,
            testSetId: 5,
            totalQuestions: 10,
            correctAnswers: 9,
            incorrectAnswers: 1,
            score: 90,
            percentage: 90.0,
            strengths: 'Excellent performance across all areas.',
            areasForImprovement: 'Minor improvements needed in a few areas.',
            recommendations: 'Ready to move to more challenging material.',
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
          ),
        ];
      }

      return await _reportRepository.getReportsByUser(userId);
    } catch (e) {
      print('Error getting user reports: $e');
      rethrow;
    }
  }

  // Helper methods for generating report content
  String _generateStrengths(List<Question> questions, List<UserResponse> userResponses) {
    // In a real app, this would analyze the user's performance in different areas
    final correctCount = userResponses.where((r) => r.isCorrect == true).length;
    final percentage = (correctCount * 100) / questions.length;

    if (percentage >= 90) {
      return 'Excellent performance across all areas.';
    } else if (percentage >= 80) {
      return 'Strong performance in most areas.';
    } else if (percentage >= 70) {
      return 'Good understanding of basic concepts.';
    } else if (percentage >= 60) {
      return 'Satisfactory performance in some areas.';
    } else {
      return 'Shows potential in a few areas.';
    }
  }

  String _generateAreasForImprovement(List<Question> questions, List<UserResponse> userResponses) {
    // In a real app, this would identify specific areas where the user struggled
    final correctCount = userResponses.where((r) => r.isCorrect == true).length;
    final percentage = (correctCount * 100) / questions.length;

    if (percentage >= 90) {
      return 'Minor improvements needed in a few areas.';
    } else if (percentage >= 80) {
      return 'Could improve on some advanced topics.';
    } else if (percentage >= 70) {
      return 'Need to work on specific problem areas.';
    } else if (percentage >= 60) {
      return 'Significant improvement needed in several areas.';
    } else {
      return 'Fundamental concepts need strengthening.';
    }
  }

  String _generateRecommendations(List<Question> questions, List<UserResponse> userResponses, double percentage) {
    // In a real app, this would provide personalized recommendations
    if (percentage >= 90) {
      return 'Ready to move to more challenging material.';
    } else if (percentage >= 80) {
      return 'Focus on advanced topics to improve further.';
    } else if (percentage >= 70) {
      return 'Review specific areas where you made mistakes.';
    } else if (percentage >= 60) {
      return 'Practice more questions and review basic concepts.';
    } else {
      return 'Consider revisiting fundamental concepts before proceeding.';
    }
  }
}
