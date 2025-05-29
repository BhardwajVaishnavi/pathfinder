import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/models.dart';
import '../repositories/repositories.dart';
import 'achievement_service.dart';
import 'auth_service.dart';
import 'multi_user_auth_service.dart';

class TestService {
  static final TestService _instance = TestService._internal();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final TestSetRepository _testSetRepository = TestSetRepository();
  final QuestionRepository _questionRepository = QuestionRepository();
  final UserResponseRepository _userResponseRepository = UserResponseRepository();
  final ReportRepository _reportRepository = ReportRepository();
  final MultiUserAuthService _authService = MultiUserAuthService();
  final AchievementService _achievementService = AchievementService();

  factory TestService() {
    return _instance;
  }

  TestService._internal();

  // Get all categories
  Future<List<Category>> getCategories() async {
    try {
      // Always return static data - no database dependency
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
    } catch (e) {
      print('Error getting categories: $e');
      rethrow;
    }
  }

  // Get categories filtered by student's education level
  Future<List<Category>> getCategoriesForStudent() async {
    try {
      final authService = MultiUserAuthService();

      if (!authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      // Get the current user's education category
      final currentUser = authService.currentUser;
      if (currentUser == null) {
        throw Exception('User profile not found');
      }

      // Map education category to category ID
      int userCategoryId = _getEducationCategoryId(currentUser.educationCategory);

      // All available categories
      final allCategories = [
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

      // Filter to show only the student's education category
      final filteredCategories = allCategories.where((category) => category.id == userCategoryId).toList();

      // Get education category string safely without using .value
      String educationCategoryStr = 'Unknown';
      if (currentUser.educationCategory != null) {
        educationCategoryStr = currentUser.educationCategory.toString().split('.').last;
      }

      print('✅ Student ${currentUser.name} ($educationCategoryStr) can see category: ${filteredCategories.map((c) => c.name).join(', ')}');

      return filteredCategories;
    } catch (e) {
      print('Error getting categories for student: $e');
      rethrow;
    }
  }

  // Helper method to map education category to category ID
  int _getEducationCategoryId(EducationCategory? educationCategory) {
    if (educationCategory == null) return 2; // Default to 10th Pass

    switch (educationCategory) {
      case EducationCategory.tenthFail:
        return 1;
      case EducationCategory.tenthPass:
        return 2;
      case EducationCategory.twelfthFail:
        return 3;
      case EducationCategory.twelfthPass:
        return 4;
      case EducationCategory.graduateScience:
        return 5;
      case EducationCategory.graduateCommerce:
        return 6;
      case EducationCategory.graduateArts:
        return 7;
      case EducationCategory.engineeringCSE:
      case EducationCategory.engineeringECE:
      case EducationCategory.engineeringMechanical:
      case EducationCategory.engineeringCivil:
      case EducationCategory.engineeringOther:
        return 8; // All engineering categories map to Graduate (BTech)
      case EducationCategory.postgraduate:
        return 9;
      default:
        return 2; // Default to 10th Pass
    }
  }

  // Get test sets for a category with student-specific shuffling
  Future<List<TestSet>> getTestSetsForCategory(int categoryId) async {
    try {
      final authService = MultiUserAuthService();

      if (!authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      final currentUser = authService.currentUser;
      if (currentUser == null) {
        throw Exception('User profile not found');
      }

      // Generate 2 test sets for the category (1 Aptitude + 1 Psychometric)
      List<TestSet> testSets = [];

      // Generate 1 Aptitude Test Set
      testSets.add(TestSet(
        id: categoryId * 100 + 1, // Aptitude test ID
        categoryId: categoryId,
        title: 'Aptitude Test',
        description: 'Logical reasoning, numerical ability, and problem-solving skills assessment',
        timeLimit: 45, // 45 minutes for aptitude
        passingScore: 70,
      ));

      // Generate 1 Psychometric Test Set
      testSets.add(TestSet(
        id: categoryId * 100 + 51, // Psychometric test ID (51 to differentiate)
        categoryId: categoryId,
        title: 'Psychometric Test',
        description: 'Personality traits, behavioral patterns, and cognitive abilities assessment',
        timeLimit: 45, // 45 minutes for psychometric
        passingScore: 70,
      ));

      // Keep test sets in consistent order (Aptitude first, then Psychometric)
      // No need to shuffle since there are only 2 tests
      print('✅ Test sets created for student ${currentUser.name} (ID: ${currentUser.id}) - 1 Aptitude + 1 Psychometric');

      return testSets;
    } catch (e) {
      print('Error getting test sets: $e');
      rethrow;
    }
  }

  // Get questions for a test set
  Future<List<Question>> getQuestionsForTestSet(int testSetId) async {
    try {
      // Always use static data - no database dependency
      // Get category ID from test set ID
      int categoryId = (testSetId ~/ 100);

      // Determine if this is an Aptitude or Psychometric test
      bool isAptitudeTest = (testSetId % 100) <= 50;

      return _getQuestionsForCategory(categoryId, testSetId, isAptitudeTest);
    } catch (e) {
      print('Error getting questions: $e');
      rethrow;
    }
  }

  // Generate category-specific questions
  List<Question> _getQuestionsForCategory(int categoryId, int testSetId, bool isAptitudeTest) {
    List<Map<String, dynamic>> questionData = [];

    if (isAptitudeTest) {
      // Get Aptitude questions based on education category
      switch (categoryId) {
        case 1: // 10th Fail
          questionData = _get10thFailAptitudeQuestions();
          break;
        case 2: // 10th Pass
          questionData = _get10thPassAptitudeQuestions();
          break;
        case 3: // 12th Fail
          questionData = _get12thFailAptitudeQuestions();
          break;
        case 4: // 12th Pass
          questionData = _get12thPassAptitudeQuestions();
          break;
        case 5: // Graduate Science
          questionData = _getGraduateScienceAptitudeQuestions();
          break;
        case 6: // Graduate Commerce
          questionData = _getGraduateCommerceAptitudeQuestions();
          break;
        case 7: // Graduate Arts
          questionData = _getGraduateArtsAptitudeQuestions();
          break;
        case 8: // Graduate BTech
          questionData = _getGraduateBTechAptitudeQuestions();
          break;
        case 9: // Postgraduate
          questionData = _getPostgraduateAptitudeQuestions();
          break;
        default:
          questionData = _getGeneralAptitudeQuestions();
      }
    } else {
      // Get Psychometric questions based on education category
      switch (categoryId) {
        case 1: // 10th Fail
          questionData = _get10thFailPsychometricQuestions();
          break;
        case 2: // 10th Pass
          questionData = _get10thPassPsychometricQuestions();
          break;
        case 3: // 12th Fail
          questionData = _get12thFailPsychometricQuestions();
          break;
        case 4: // 12th Pass
          questionData = _get12thPassPsychometricQuestions();
          break;
        case 5: // Graduate Science
          questionData = _getGraduateSciencePsychometricQuestions();
          break;
        case 6: // Graduate Commerce
          questionData = _getGraduateCommercePsychometricQuestions();
          break;
        case 7: // Graduate Arts
          questionData = _getGraduateArtsPsychometricQuestions();
          break;
        case 8: // Graduate BTech
          questionData = _getGraduateBTechPsychometricQuestions();
          break;
        case 9: // Postgraduate
          questionData = _getPostgraduatePsychometricQuestions();
          break;
        default:
          questionData = _getGeneralPsychometricQuestions();
      }
    }

    // Shuffle questions based on student and test set for consistent but different experience
    final authService = MultiUserAuthService();
    final currentUser = authService.currentUser;

    if (currentUser != null) {
      // Create a unique seed for this student and test set combination
      final shuffleSeed = currentUser.id.hashCode + currentUser.name.hashCode + testSetId.hashCode;
      final random = Random(shuffleSeed);
      questionData.shuffle(random);
      print('✅ Questions shuffled for ${currentUser.name} - Test Set $testSetId');
    } else {
      questionData.shuffle();
    }

    // Take 15 questions
    questionData = questionData.take(15).toList();

    return questionData.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> q = entry.value;

      return Question(
        id: testSetId * 100 + index + 1,
        testSetId: testSetId,
        questionText: q['question'],
        optionA: q['optionA'],
        optionB: q['optionB'],
        optionC: q['optionC'],
        optionD: q['optionD'],
        correctOption: q['correct'],
        explanation: q['explanation'],
      );
    }).toList();
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
        id: DateTime.now().millisecondsSinceEpoch, // Use timestamp as ID for web
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

      // For web platform, return the report directly without database operations
      if (kIsWeb) {
        print('✅ Test submitted successfully on web platform');
        print('📊 Report generated: ${report.percentage?.toStringAsFixed(1)}% score');
        return report;
      }

      // For mobile/production, save to database
      try {
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
        print('⚠️ Database save failed, returning report anyway: $e');
        return report;
      }
    } catch (e) {
      print('Error submitting test: $e');
      rethrow;
    }
  }

  // Get reports for current user
  Future<List<Report>> getUserReports() async {
    try {
      final authService = MultiUserAuthService();

      if (!authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      // Always return empty list - no demo data
      return [];
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

  // 10th Fail Aptitude Questions - Basic numerical and logical reasoning
  List<Map<String, dynamic>> _get10thFailAptitudeQuestions() {
    return [
      {
        'question': 'If you have 5 apples and you give away 2, how many apples do you have left?',
        'optionA': '2 apples',
        'optionB': '3 apples',
        'optionC': '4 apples',
        'optionD': '5 apples',
        'correct': 'B',
        'explanation': 'Simple subtraction: 5 - 2 = 3 apples remaining.'
      },
      {
        'question': 'If a shop opens at 9 AM and closes at 6 PM, how many hours is it open?',
        'optionA': '8 hours',
        'optionB': '9 hours',
        'optionC': '10 hours',
        'optionD': '7 hours',
        'correct': 'B',
        'explanation': 'From 9 AM to 6 PM is 9 hours (9 AM to 12 PM = 3 hours, 12 PM to 6 PM = 6 hours).'
      },
      {
        'question': 'What comes next in the sequence: 2, 4, 6, 8, ?',
        'optionA': '9',
        'optionB': '10',
        'optionC': '11',
        'optionD': '12',
        'correct': 'B',
        'explanation': 'This is a sequence of even numbers: 2, 4, 6, 8, 10.'
      },
      {
        'question': 'If 1 dozen = 12 items, how many items are in 3 dozen?',
        'optionA': '24',
        'optionB': '30',
        'optionC': '36',
        'optionD': '42',
        'correct': 'C',
        'explanation': '3 dozen = 3 × 12 = 36 items.'
      },
      {
        'question': 'Which number is the largest?',
        'optionA': '0.5',
        'optionB': '0.25',
        'optionC': '0.75',
        'optionD': '0.1',
        'correct': 'C',
        'explanation': '0.75 is the largest among the given decimal numbers.'
      },
      {
        'question': 'If you buy 3 pens for ₹15, what is the cost of 1 pen?',
        'optionA': '₹3',
        'optionB': '₹4',
        'optionC': '₹5',
        'optionD': '₹6',
        'correct': 'C',
        'explanation': 'Cost of 1 pen = ₹15 ÷ 3 = ₹5.'
      },
      {
        'question': 'What is 10% of 50?',
        'optionA': '3',
        'optionB': '4',
        'optionC': '5',
        'optionD': '6',
        'correct': 'C',
        'explanation': '10% of 50 = (10/100) × 50 = 5.'
      },
      {
        'question': 'If today is Monday, what day will it be after 3 days?',
        'optionA': 'Tuesday',
        'optionB': 'Wednesday',
        'optionC': 'Thursday',
        'optionD': 'Friday',
        'correct': 'C',
        'explanation': 'Monday + 3 days = Thursday.'
      },
      {
        'question': 'Which is heavier: 1 kg of cotton or 1 kg of iron?',
        'optionA': 'Cotton',
        'optionB': 'Iron',
        'optionC': 'Both are equal',
        'optionD': 'Cannot determine',
        'correct': 'C',
        'explanation': 'Both weigh exactly 1 kg, so they are equal in weight.'
      },
      {
        'question': 'If a bus travels 60 km in 2 hours, what is its speed?',
        'optionA': '20 km/hr',
        'optionB': '25 km/hr',
        'optionC': '30 km/hr',
        'optionD': '35 km/hr',
        'correct': 'C',
        'explanation': 'Speed = Distance ÷ Time = 60 km ÷ 2 hours = 30 km/hr.'
      },
      {
        'question': 'What is the sum of 25 + 35?',
        'optionA': '50',
        'optionB': '55',
        'optionC': '60',
        'optionD': '65',
        'correct': 'C',
        'explanation': '25 + 35 = 60.'
      },
      {
        'question': 'If you have ₹100 and spend ₹35, how much money is left?',
        'optionA': '₹55',
        'optionB': '₹60',
        'optionC': '₹65',
        'optionD': '₹70',
        'correct': 'C',
        'explanation': '₹100 - ₹35 = ₹65.'
      },
      {
        'question': 'How many minutes are there in 2 hours?',
        'optionA': '100 minutes',
        'optionB': '110 minutes',
        'optionC': '120 minutes',
        'optionD': '130 minutes',
        'correct': 'C',
        'explanation': '2 hours = 2 × 60 minutes = 120 minutes.'
      },
      {
        'question': 'Which shape has 3 sides?',
        'optionA': 'Square',
        'optionB': 'Rectangle',
        'optionC': 'Triangle',
        'optionD': 'Circle',
        'correct': 'C',
        'explanation': 'A triangle has exactly 3 sides.'
      },
      {
        'question': 'If 5 + 3 = 8, then 8 - 3 = ?',
        'optionA': '3',
        'optionB': '4',
        'optionC': '5',
        'optionD': '6',
        'correct': 'C',
        'explanation': '8 - 3 = 5.'
      },
      {
        'question': 'What is half of 20?',
        'optionA': '8',
        'optionB': '9',
        'optionC': '10',
        'optionD': '11',
        'correct': 'C',
        'explanation': 'Half of 20 = 20 ÷ 2 = 10.'
      },
      {
        'question': 'If you arrange numbers 3, 1, 5, 2 in ascending order, what comes first?',
        'optionA': '1',
        'optionB': '2',
        'optionC': '3',
        'optionD': '5',
        'correct': 'A',
        'explanation': 'In ascending order: 1, 2, 3, 5. So 1 comes first.'
      },
      {
        'question': 'How many days are there in a week?',
        'optionA': '5',
        'optionB': '6',
        'optionC': '7',
        'optionD': '8',
        'correct': 'C',
        'explanation': 'There are 7 days in a week.'
      },
      {
        'question': 'If you double the number 15, what do you get?',
        'optionA': '25',
        'optionB': '30',
        'optionC': '35',
        'optionD': '40',
        'correct': 'B',
        'explanation': 'Double of 15 = 15 × 2 = 30.'
      },
      {
        'question': 'What is 100 - 25?',
        'optionA': '65',
        'optionB': '70',
        'optionC': '75',
        'optionD': '80',
        'correct': 'C',
        'explanation': '100 - 25 = 75.'
      }
    ];
  }

  // 10th Fail Psychometric Questions - Basic personality and behavioral assessment
  List<Map<String, dynamic>> _get10thFailPsychometricQuestions() {
    return [
      {
        'question': 'What is the best way to learn a new skill?',
        'optionA': 'Practice regularly',
        'optionB': 'Read about it once',
        'optionC': 'Watch others do it',
        'optionD': 'Think about it',
        'correct': 'A',
        'explanation': 'Regular practice is the most effective way to master any skill.'
      },
      {
        'question': 'Which of these is most important for getting a job?',
        'optionA': 'Good appearance only',
        'optionB': 'Skills and attitude',
        'optionC': 'Knowing someone',
        'optionD': 'Luck',
        'correct': 'B',
        'explanation': 'Skills and positive attitude are fundamental for employment success.'
      },
      {
        'question': 'What should you do if you make a mistake at work?',
        'optionA': 'Hide it',
        'optionB': 'Blame someone else',
        'optionC': 'Admit it and learn',
        'optionD': 'Ignore it',
        'correct': 'C',
        'explanation': 'Honesty and learning from mistakes shows maturity and responsibility.'
      },
      {
        'question': 'When working in a team, what is most important?',
        'optionA': 'Being the leader always',
        'optionB': 'Working alone',
        'optionC': 'Cooperating with others',
        'optionD': 'Competing with teammates',
        'correct': 'C',
        'explanation': 'Cooperation and teamwork are essential for team success.'
      },
      {
        'question': 'How do you handle stress?',
        'optionA': 'Ignore the problem',
        'optionB': 'Take breaks and plan',
        'optionC': 'Get angry',
        'optionD': 'Give up immediately',
        'correct': 'B',
        'explanation': 'Taking breaks and planning helps manage stress effectively.'
      },
      {
        'question': 'What motivates you most to work hard?',
        'optionA': 'Fear of punishment',
        'optionB': 'Personal growth',
        'optionC': 'Money only',
        'optionD': 'Peer pressure',
        'correct': 'B',
        'explanation': 'Personal growth provides sustainable motivation for long-term success.'
      },
      {
        'question': 'When you disagree with someone, you should:',
        'optionA': 'Argue loudly',
        'optionB': 'Stay silent always',
        'optionC': 'Listen and discuss respectfully',
        'optionD': 'Walk away immediately',
        'correct': 'C',
        'explanation': 'Respectful discussion helps resolve disagreements constructively.'
      },
      {
        'question': 'What is the best approach to solving a problem?',
        'optionA': 'Rush to find any solution',
        'optionB': 'Think carefully and plan',
        'optionC': 'Ask others to solve it',
        'optionD': 'Avoid the problem',
        'correct': 'B',
        'explanation': 'Careful thinking and planning lead to better solutions.'
      },
      {
        'question': 'How important is it to be on time?',
        'optionA': 'Not important',
        'optionB': 'Sometimes important',
        'optionC': 'Very important',
        'optionD': 'Only for special occasions',
        'correct': 'C',
        'explanation': 'Being punctual shows respect and professionalism.'
      },
      {
        'question': 'When you receive feedback, you should:',
        'optionA': 'Ignore it',
        'optionB': 'Get defensive',
        'optionC': 'Listen and improve',
        'optionD': 'Argue back',
        'correct': 'C',
        'explanation': 'Listening to feedback and using it for improvement shows maturity.'
      },
      {
        'question': 'What is most important for personal development?',
        'optionA': 'Staying in comfort zone',
        'optionB': 'Learning new things',
        'optionC': 'Avoiding challenges',
        'optionD': 'Following others blindly',
        'correct': 'B',
        'explanation': 'Continuous learning is key to personal and professional growth.'
      },
      {
        'question': 'How do you prefer to communicate?',
        'optionA': 'Only through messages',
        'optionB': 'Face to face when possible',
        'optionC': 'Avoid communication',
        'optionD': 'Only when necessary',
        'correct': 'B',
        'explanation': 'Face-to-face communication is often more effective and builds better relationships.'
      },
      {
        'question': 'When facing a difficult task, you:',
        'optionA': 'Give up immediately',
        'optionB': 'Try your best',
        'optionC': 'Wait for help',
        'optionD': 'Complain about it',
        'correct': 'B',
        'explanation': 'Trying your best shows determination and resilience.'
      },
      {
        'question': 'What is your approach to learning from others?',
        'optionA': 'I know everything',
        'optionB': 'I can learn from anyone',
        'optionC': 'Only from experts',
        'optionD': 'Learning is not important',
        'correct': 'B',
        'explanation': 'Being open to learning from anyone shows humility and growth mindset.'
      },
      {
        'question': 'How do you handle responsibility?',
        'optionA': 'Avoid it',
        'optionB': 'Accept it willingly',
        'optionC': 'Pass it to others',
        'optionD': 'Complain about it',
        'correct': 'B',
        'explanation': 'Accepting responsibility willingly shows maturity and reliability.'
      },
      {
        'question': 'What is most important in building relationships?',
        'optionA': 'Trust and respect',
        'optionB': 'Money and gifts',
        'optionC': 'Power and control',
        'optionD': 'Competition',
        'correct': 'A',
        'explanation': 'Trust and respect are the foundation of healthy relationships.'
      },
      {
        'question': 'When you make a promise, you should:',
        'optionA': 'Keep it always',
        'optionB': 'Keep it sometimes',
        'optionC': 'Forget about it',
        'optionD': 'Make excuses',
        'correct': 'A',
        'explanation': 'Keeping promises builds trust and shows reliability.'
      },
      {
        'question': 'How do you react to change?',
        'optionA': 'Resist it always',
        'optionB': 'Adapt and learn',
        'optionC': 'Ignore it',
        'optionD': 'Complain about it',
        'correct': 'B',
        'explanation': 'Adapting to change and learning from it is essential for growth.'
      },
      {
        'question': 'What drives you to achieve your goals?',
        'optionA': 'External pressure',
        'optionB': 'Personal satisfaction',
        'optionC': 'Fear of failure',
        'optionD': 'Others\' expectations',
        'correct': 'B',
        'explanation': 'Personal satisfaction provides sustainable motivation for achieving goals.'
      },
      {
        'question': 'How important is honesty in your life?',
        'optionA': 'Not important',
        'optionB': 'Sometimes important',
        'optionC': 'Very important',
        'optionD': 'Depends on situation',
        'correct': 'C',
        'explanation': 'Honesty is fundamental for building trust and maintaining integrity.'
      }
    ];
  }

  // 10th Pass Questions - Basic academic and reasoning
  List<Map<String, dynamic>> _get10thPassQuestions() {
    return [
      {
        'question': 'What is 15% of 200?',
        'optionA': '25',
        'optionB': '30',
        'optionC': '35',
        'optionD': '40',
        'correct': 'B',
        'explanation': '15% of 200 = (15/100) × 200 = 30.'
      },
      {
        'question': 'Which planet is closest to the Sun?',
        'optionA': 'Venus',
        'optionB': 'Earth',
        'optionC': 'Mercury',
        'optionD': 'Mars',
        'correct': 'C',
        'explanation': 'Mercury is the planet closest to the Sun in our solar system.'
      },
      {
        'question': 'If BOOK is coded as CPPL, then DESK is coded as:',
        'optionA': 'EFTL',
        'optionB': 'EFSL',
        'optionC': 'DFTL',
        'optionD': 'EFTK',
        'correct': 'A',
        'explanation': 'Each letter is shifted by +1: D→E, E→F, S→T, K→L.'
      },
      {
        'question': 'What is the capital of India?',
        'optionA': 'Mumbai',
        'optionB': 'New Delhi',
        'optionC': 'Kolkata',
        'optionD': 'Chennai',
        'correct': 'B',
        'explanation': 'New Delhi is the capital city of India.'
      },
      {
        'question': 'In a sequence 2, 4, 8, 16, what comes next?',
        'optionA': '24',
        'optionB': '32',
        'optionC': '20',
        'optionD': '18',
        'correct': 'B',
        'explanation': 'Each number is doubled: 2×2=4, 4×2=8, 8×2=16, 16×2=32.'
      },
    ];
  }

  // 12th Fail Questions - Intermediate level with focus on practical skills
  List<Map<String, dynamic>> _get12thFailQuestions() {
    return [
      {
        'question': 'If the cost price of an item is ₹80 and selling price is ₹100, what is the profit percentage?',
        'optionA': '20%',
        'optionB': '25%',
        'optionC': '30%',
        'optionD': '15%',
        'correct': 'B',
        'explanation': 'Profit = 100-80 = 20. Profit% = (20/80) × 100 = 25%.'
      },
      {
        'question': 'Which of these soft skills is most important in the workplace?',
        'optionA': 'Communication',
        'optionB': 'Technical knowledge only',
        'optionC': 'Working alone',
        'optionD': 'Following orders blindly',
        'correct': 'A',
        'explanation': 'Communication is essential for teamwork, problem-solving, and career growth.'
      },
      {
        'question': 'What does "www" stand for in a website address?',
        'optionA': 'World Wide Web',
        'optionB': 'World Wide Work',
        'optionC': 'World Wide Wire',
        'optionD': 'World Wide Win',
        'correct': 'A',
        'explanation': 'WWW stands for World Wide Web, the information system on the Internet.'
      },
      {
        'question': 'If a train travels 60 km in 45 minutes, what is its speed in km/hr?',
        'optionA': '75 km/hr',
        'optionB': '80 km/hr',
        'optionC': '85 km/hr',
        'optionD': '90 km/hr',
        'correct': 'B',
        'explanation': 'Speed = Distance/Time = 60 km / (45/60) hr = 60 × (60/45) = 80 km/hr.'
      },
      {
        'question': 'Which career path typically requires continuous learning and adaptation?',
        'optionA': 'All modern careers',
        'optionB': 'Only technical jobs',
        'optionC': 'Only creative jobs',
        'optionD': 'Only management roles',
        'correct': 'A',
        'explanation': 'In today\'s rapidly changing world, all careers require continuous learning.'
      },
    ];
  }

  // 12th Pass Questions - Higher secondary level reasoning and knowledge
  List<Map<String, dynamic>> _get12thPassQuestions() {
    return [
      {
        'question': 'What is the derivative of x² + 3x + 2?',
        'optionA': '2x + 3',
        'optionB': 'x + 3',
        'optionC': '2x + 2',
        'optionD': 'x² + 3',
        'correct': 'A',
        'explanation': 'The derivative of x² is 2x, derivative of 3x is 3, and derivative of constant 2 is 0.'
      },
      {
        'question': 'Who wrote the novel "Pride and Prejudice"?',
        'optionA': 'Charlotte Brontë',
        'optionB': 'Jane Austen',
        'optionC': 'Emily Dickinson',
        'optionD': 'Virginia Woolf',
        'correct': 'B',
        'explanation': 'Jane Austen wrote "Pride and Prejudice" in 1813.'
      },
      {
        'question': 'What is the chemical formula for water?',
        'optionA': 'H2O',
        'optionB': 'CO2',
        'optionC': 'NaCl',
        'optionD': 'CH4',
        'correct': 'A',
        'explanation': 'Water consists of two hydrogen atoms and one oxygen atom: H2O.'
      },
      {
        'question': 'In which year did India gain independence?',
        'optionA': '1945',
        'optionB': '1946',
        'optionC': '1947',
        'optionD': '1948',
        'correct': 'C',
        'explanation': 'India gained independence from British rule on August 15, 1947.'
      },
      {
        'question': 'What is the square root of 144?',
        'optionA': '11',
        'optionB': '12',
        'optionC': '13',
        'optionD': '14',
        'correct': 'B',
        'explanation': '12 × 12 = 144, so √144 = 12.'
      },
    ];
  }

  // Graduate Science Questions - Advanced scientific reasoning
  List<Map<String, dynamic>> _getGraduateScienceQuestions() {
    return [
      {
        'question': 'What is the molecular formula of glucose?',
        'optionA': 'C6H12O6',
        'optionB': 'C12H22O11',
        'optionC': 'C2H6O',
        'optionD': 'CH4',
        'correct': 'A',
        'explanation': 'Glucose has the molecular formula C6H12O6, a simple sugar essential for cellular energy.'
      },
      {
        'question': 'Which principle explains why airplanes can fly?',
        'optionA': 'Newton\'s Third Law',
        'optionB': 'Bernoulli\'s Principle',
        'optionC': 'Archimedes\' Principle',
        'optionD': 'Pascal\'s Law',
        'correct': 'B',
        'explanation': 'Bernoulli\'s Principle explains how air pressure differences create lift for aircraft.'
      },
      {
        'question': 'What is the pH of pure water at 25°C?',
        'optionA': '6',
        'optionB': '7',
        'optionC': '8',
        'optionD': '9',
        'correct': 'B',
        'explanation': 'Pure water has a pH of 7, which is neutral on the pH scale.'
      },
      {
        'question': 'Which organelle is known as the powerhouse of the cell?',
        'optionA': 'Nucleus',
        'optionB': 'Ribosome',
        'optionC': 'Mitochondria',
        'optionD': 'Endoplasmic Reticulum',
        'correct': 'C',
        'explanation': 'Mitochondria produce ATP, the energy currency of cells, earning the title "powerhouse".'
      },
      {
        'question': 'What is the speed of light in vacuum?',
        'optionA': '3 × 10⁸ m/s',
        'optionB': '3 × 10⁶ m/s',
        'optionC': '3 × 10¹⁰ m/s',
        'optionD': '3 × 10⁴ m/s',
        'correct': 'A',
        'explanation': 'The speed of light in vacuum is approximately 3 × 10⁸ meters per second.'
      },
    ];
  }

  // Graduate Commerce Questions - Business and economics focus
  List<Map<String, dynamic>> _getGraduateCommerceQuestions() {
    return [
      {
        'question': 'What does ROI stand for in business?',
        'optionA': 'Return on Investment',
        'optionB': 'Rate of Interest',
        'optionC': 'Risk of Investment',
        'optionD': 'Revenue of Industry',
        'correct': 'A',
        'explanation': 'ROI (Return on Investment) measures the efficiency of an investment.'
      },
      {
        'question': 'In accounting, what is the fundamental equation?',
        'optionA': 'Assets = Liabilities + Equity',
        'optionB': 'Revenue = Expenses + Profit',
        'optionC': 'Cash = Assets - Liabilities',
        'optionD': 'Profit = Revenue - Costs',
        'correct': 'A',
        'explanation': 'The accounting equation: Assets = Liabilities + Owner\'s Equity is fundamental to double-entry bookkeeping.'
      },
      {
        'question': 'What is inflation?',
        'optionA': 'Decrease in money supply',
        'optionB': 'Increase in general price level',
        'optionC': 'Decrease in interest rates',
        'optionD': 'Increase in employment',
        'correct': 'B',
        'explanation': 'Inflation is the sustained increase in the general price level of goods and services.'
      },
      {
        'question': 'Which market structure has only one seller?',
        'optionA': 'Perfect Competition',
        'optionB': 'Oligopoly',
        'optionC': 'Monopoly',
        'optionD': 'Monopolistic Competition',
        'correct': 'C',
        'explanation': 'A monopoly is a market structure with a single seller and no close substitutes.'
      },
      {
        'question': 'What is the primary function of a central bank?',
        'optionA': 'Provide loans to individuals',
        'optionB': 'Control monetary policy',
        'optionC': 'Manage corporate accounts',
        'optionD': 'Issue credit cards',
        'correct': 'B',
        'explanation': 'Central banks primarily control monetary policy, including money supply and interest rates.'
      },
    ];
  }

  // Graduate Arts Questions - Literature, history, and social sciences
  List<Map<String, dynamic>> _getGraduateArtsQuestions() {
    return [
      {
        'question': 'Who wrote "The Great Gatsby"?',
        'optionA': 'Ernest Hemingway',
        'optionB': 'F. Scott Fitzgerald',
        'optionC': 'John Steinbeck',
        'optionD': 'William Faulkner',
        'correct': 'B',
        'explanation': 'F. Scott Fitzgerald wrote "The Great Gatsby" in 1925, a classic of American literature.'
      },
      {
        'question': 'Which psychological theory emphasizes unconscious motivations?',
        'optionA': 'Behaviorism',
        'optionB': 'Cognitive Theory',
        'optionC': 'Psychoanalytic Theory',
        'optionD': 'Humanistic Theory',
        'correct': 'C',
        'explanation': 'Psychoanalytic theory, developed by Freud, emphasizes unconscious drives and motivations.'
      },
      {
        'question': 'What is the study of human societies and cultures called?',
        'optionA': 'Psychology',
        'optionB': 'Anthropology',
        'optionC': 'Sociology',
        'optionD': 'Philosophy',
        'correct': 'B',
        'explanation': 'Anthropology is the study of human societies, cultures, and their development.'
      },
      {
        'question': 'Which art movement is Pablo Picasso associated with?',
        'optionA': 'Impressionism',
        'optionB': 'Cubism',
        'optionC': 'Surrealism',
        'optionD': 'Abstract Expressionism',
        'correct': 'B',
        'explanation': 'Pablo Picasso co-founded Cubism, revolutionizing modern art in the early 20th century.'
      },
      {
        'question': 'What is the main focus of existentialist philosophy?',
        'optionA': 'Individual existence and freedom',
        'optionB': 'Mathematical logic',
        'optionC': 'Scientific method',
        'optionD': 'Religious doctrine',
        'correct': 'A',
        'explanation': 'Existentialism focuses on individual existence, freedom, and choice in creating meaning.'
      },
    ];
  }

  // Graduate BTech Questions - Engineering and technology
  List<Map<String, dynamic>> _getGraduateBTechQuestions() {
    return [
      {
        'question': 'What is the time complexity of binary search?',
        'optionA': 'O(n)',
        'optionB': 'O(log n)',
        'optionC': 'O(n²)',
        'optionD': 'O(1)',
        'correct': 'B',
        'explanation': 'Binary search has O(log n) time complexity as it halves the search space each iteration.'
      },
      {
        'question': 'Which programming paradigm does Java primarily support?',
        'optionA': 'Functional Programming',
        'optionB': 'Object-Oriented Programming',
        'optionC': 'Procedural Programming',
        'optionD': 'Logic Programming',
        'correct': 'B',
        'explanation': 'Java is primarily an object-oriented programming language with classes and objects.'
      },
      {
        'question': 'What does CPU stand for?',
        'optionA': 'Central Processing Unit',
        'optionB': 'Computer Processing Unit',
        'optionC': 'Central Program Unit',
        'optionD': 'Computer Program Unit',
        'correct': 'A',
        'explanation': 'CPU stands for Central Processing Unit, the main processor of a computer.'
      },
      {
        'question': 'In database design, what does ACID stand for?',
        'optionA': 'Atomicity, Consistency, Isolation, Durability',
        'optionB': 'Access, Control, Integration, Design',
        'optionC': 'Application, Code, Interface, Database',
        'optionD': 'Analysis, Creation, Implementation, Deployment',
        'correct': 'A',
        'explanation': 'ACID represents the four key properties of database transactions: Atomicity, Consistency, Isolation, Durability.'
      },
      {
        'question': 'What is the primary purpose of an operating system?',
        'optionA': 'Run applications only',
        'optionB': 'Manage hardware and software resources',
        'optionC': 'Store data permanently',
        'optionD': 'Connect to the internet',
        'correct': 'B',
        'explanation': 'An operating system manages computer hardware and software resources and provides services for programs.'
      },
    ];
  }

  // Postgraduate Questions - Advanced analytical and research-oriented
  List<Map<String, dynamic>> _getPostgraduateQuestions() {
    return [
      {
        'question': 'What is the primary goal of research methodology?',
        'optionA': 'To prove existing theories',
        'optionB': 'To systematically investigate problems',
        'optionC': 'To collect random data',
        'optionD': 'To support personal opinions',
        'correct': 'B',
        'explanation': 'Research methodology provides systematic approaches to investigate and solve problems scientifically.'
      },
      {
        'question': 'In statistics, what does a p-value represent?',
        'optionA': 'Probability of the hypothesis being true',
        'optionB': 'Probability of observing results given null hypothesis is true',
        'optionC': 'Percentage of variance explained',
        'optionD': 'Population parameter value',
        'correct': 'B',
        'explanation': 'P-value represents the probability of observing the results (or more extreme) assuming the null hypothesis is true.'
      },
      {
        'question': 'What is the key characteristic of peer-reviewed research?',
        'optionA': 'Published quickly',
        'optionB': 'Evaluated by experts in the field',
        'optionC': 'Available for free',
        'optionD': 'Written by famous authors',
        'correct': 'B',
        'explanation': 'Peer-reviewed research is evaluated by independent experts in the field before publication.'
      },
      {
        'question': 'Which sampling method ensures every member has equal chance of selection?',
        'optionA': 'Convenience sampling',
        'optionB': 'Purposive sampling',
        'optionC': 'Random sampling',
        'optionD': 'Snowball sampling',
        'correct': 'C',
        'explanation': 'Random sampling gives every member of the population an equal chance of being selected.'
      },
      {
        'question': 'What is the main advantage of longitudinal studies?',
        'optionA': 'Quick results',
        'optionB': 'Low cost',
        'optionC': 'Track changes over time',
        'optionD': 'Large sample sizes',
        'correct': 'C',
        'explanation': 'Longitudinal studies track the same subjects over time, allowing observation of changes and trends.'
      },
    ];
  }

  // Placeholder methods for all other education categories
  // These return the 10th Fail questions as a base - can be customized later

  // 10th Pass Aptitude & Psychometric
  List<Map<String, dynamic>> _get10thPassAptitudeQuestions() => _get10thFailAptitudeQuestions();
  List<Map<String, dynamic>> _get10thPassPsychometricQuestions() => _get10thFailPsychometricQuestions();

  // 12th Fail Aptitude & Psychometric
  List<Map<String, dynamic>> _get12thFailAptitudeQuestions() => _get10thFailAptitudeQuestions();
  List<Map<String, dynamic>> _get12thFailPsychometricQuestions() => _get10thFailPsychometricQuestions();

  // 12th Pass Aptitude & Psychometric
  List<Map<String, dynamic>> _get12thPassAptitudeQuestions() => _get10thFailAptitudeQuestions();
  List<Map<String, dynamic>> _get12thPassPsychometricQuestions() => _get10thFailPsychometricQuestions();

  // Graduate Science Aptitude & Psychometric
  List<Map<String, dynamic>> _getGraduateScienceAptitudeQuestions() => _get10thFailAptitudeQuestions();
  List<Map<String, dynamic>> _getGraduateSciencePsychometricQuestions() => _get10thFailPsychometricQuestions();

  // Graduate Commerce Aptitude & Psychometric
  List<Map<String, dynamic>> _getGraduateCommerceAptitudeQuestions() => _get10thFailAptitudeQuestions();
  List<Map<String, dynamic>> _getGraduateCommercePsychometricQuestions() => _get10thFailPsychometricQuestions();

  // Graduate Arts Aptitude & Psychometric
  List<Map<String, dynamic>> _getGraduateArtsAptitudeQuestions() => _get10thFailAptitudeQuestions();
  List<Map<String, dynamic>> _getGraduateArtsPsychometricQuestions() => _get10thFailPsychometricQuestions();

  // Graduate BTech Aptitude & Psychometric
  List<Map<String, dynamic>> _getGraduateBTechAptitudeQuestions() => _get10thFailAptitudeQuestions();
  List<Map<String, dynamic>> _getGraduateBTechPsychometricQuestions() => _get10thFailPsychometricQuestions();

  // Postgraduate Aptitude & Psychometric
  List<Map<String, dynamic>> _getPostgraduateAptitudeQuestions() => _get10thFailAptitudeQuestions();
  List<Map<String, dynamic>> _getPostgraduatePsychometricQuestions() => _get10thFailPsychometricQuestions();

  // General Aptitude & Psychometric (Fallback)
  List<Map<String, dynamic>> _getGeneralAptitudeQuestions() => _get10thFailAptitudeQuestions();
  List<Map<String, dynamic>> _getGeneralPsychometricQuestions() => _get10thFailPsychometricQuestions();

  // General Questions - Fallback for any category (keeping for backward compatibility)
  List<Map<String, dynamic>> _getGeneralQuestions() {
    return [
      {
        'question': 'What is the most important skill for career success?',
        'optionA': 'Technical expertise only',
        'optionB': 'Continuous learning and adaptation',
        'optionC': 'Working in isolation',
        'optionD': 'Following instructions exactly',
        'correct': 'B',
        'explanation': 'Continuous learning and adaptation are crucial in today\'s rapidly changing work environment.'
      },
      {
        'question': 'Which approach is best for solving complex problems?',
        'optionA': 'Rushing to find quick solutions',
        'optionB': 'Breaking down into smaller parts',
        'optionC': 'Avoiding the problem',
        'optionD': 'Asking others to solve it',
        'correct': 'B',
        'explanation': 'Breaking complex problems into smaller, manageable parts makes them easier to solve systematically.'
      },
      {
        'question': 'What is emotional intelligence?',
        'optionA': 'Being highly emotional',
        'optionB': 'Understanding and managing emotions',
        'optionC': 'Avoiding emotional situations',
        'optionD': 'Expressing emotions freely',
        'correct': 'B',
        'explanation': 'Emotional intelligence involves understanding, managing, and effectively using emotions in interactions.'
      },
      {
        'question': 'Which quality is most valued by employers?',
        'optionA': 'Perfect attendance only',
        'optionB': 'Reliability and problem-solving',
        'optionC': 'Working overtime always',
        'optionD': 'Never asking questions',
        'correct': 'B',
        'explanation': 'Employers value reliability and problem-solving skills as they contribute to organizational success.'
      },
      {
        'question': 'What is the best way to handle workplace conflicts?',
        'optionA': 'Ignore them completely',
        'optionB': 'Address them constructively',
        'optionC': 'Escalate immediately',
        'optionD': 'Take sides quickly',
        'correct': 'B',
        'explanation': 'Addressing conflicts constructively through communication and understanding leads to better outcomes.'
      },
    ];
  }
}
