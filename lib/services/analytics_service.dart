import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/models.dart';
import '../repositories/repositories.dart';
import 'auth_service.dart';

class PerformanceData {
  final DateTime date;
  final double score;
  final int testSetId;
  final String? testSetTitle;
  final String? categoryName;
  
  PerformanceData({
    required this.date,
    required this.score,
    required this.testSetId,
    this.testSetTitle,
    this.categoryName,
  });
}

class CategoryPerformance {
  final int categoryId;
  final String categoryName;
  final double averageScore;
  final int testsCompleted;
  
  CategoryPerformance({
    required this.categoryId,
    required this.categoryName,
    required this.averageScore,
    required this.testsCompleted,
  });
}

class SkillPerformance {
  final String skillName;
  final double score;
  
  SkillPerformance({
    required this.skillName,
    required this.score,
  });
}

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  final ReportRepository _reportRepository = ReportRepository();
  final TestSetRepository _testSetRepository = TestSetRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final AuthService _authService = AuthService();
  
  factory AnalyticsService() {
    return _instance;
  }
  
  AnalyticsService._internal();
  
  // Get performance data for the current user
  Future<List<PerformanceData>> getPerformanceData() async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }
      
      final userId = _authService.currentUserId!;
      
      if (kIsWeb) {
        // Return mock data for web
        return [
          PerformanceData(
            date: DateTime.now().subtract(const Duration(days: 30)),
            score: 65.0,
            testSetId: 1,
            testSetTitle: 'Test Set 1',
            categoryName: '10th Fail',
          ),
          PerformanceData(
            date: DateTime.now().subtract(const Duration(days: 25)),
            score: 70.0,
            testSetId: 2,
            testSetTitle: 'Test Set 2',
            categoryName: '10th Fail',
          ),
          PerformanceData(
            date: DateTime.now().subtract(const Duration(days: 20)),
            score: 75.0,
            testSetId: 3,
            testSetTitle: 'Test Set 3',
            categoryName: '10th Pass',
          ),
          PerformanceData(
            date: DateTime.now().subtract(const Duration(days: 15)),
            score: 72.0,
            testSetId: 4,
            testSetTitle: 'Test Set 4',
            categoryName: '10th Pass',
          ),
          PerformanceData(
            date: DateTime.now().subtract(const Duration(days: 10)),
            score: 80.0,
            testSetId: 5,
            testSetTitle: 'Test Set 5',
            categoryName: '12th Fail',
          ),
          PerformanceData(
            date: DateTime.now().subtract(const Duration(days: 5)),
            score: 85.0,
            testSetId: 6,
            testSetTitle: 'Test Set 6',
            categoryName: '12th Fail',
          ),
          PerformanceData(
            date: DateTime.now().subtract(const Duration(days: 2)),
            score: 90.0,
            testSetId: 7,
            testSetTitle: 'Test Set 7',
            categoryName: '12th Pass',
          ),
        ];
      }
      
      // Get reports for the user
      final reports = await _reportRepository.getReportsByUser(userId);
      
      // Sort reports by date (oldest first)
      reports.sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
      
      // Convert reports to performance data
      final performanceData = <PerformanceData>[];
      
      for (final report in reports) {
        final testSet = await _testSetRepository.getTestSetById(report.testSetId);
        
        if (testSet != null) {
          final category = await _categoryRepository.getCategoryById(testSet.categoryId);
          
          performanceData.add(PerformanceData(
            date: report.createdAt ?? DateTime.now(),
            score: report.percentage ?? 0.0,
            testSetId: report.testSetId,
            testSetTitle: testSet.title,
            categoryName: category?.name,
          ));
        }
      }
      
      return performanceData;
    } catch (e) {
      print('Error getting performance data: $e');
      rethrow;
    }
  }
  
  // Get performance by category for the current user
  Future<List<CategoryPerformance>> getCategoryPerformance() async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }
      
      final userId = _authService.currentUserId!;
      
      if (kIsWeb) {
        // Return mock data for web
        return [
          CategoryPerformance(
            categoryId: 1,
            categoryName: '10th Fail',
            averageScore: 67.5,
            testsCompleted: 2,
          ),
          CategoryPerformance(
            categoryId: 2,
            categoryName: '10th Pass',
            averageScore: 73.5,
            testsCompleted: 2,
          ),
          CategoryPerformance(
            categoryId: 3,
            categoryName: '12th Fail',
            averageScore: 82.5,
            testsCompleted: 2,
          ),
          CategoryPerformance(
            categoryId: 4,
            categoryName: '12th Pass',
            averageScore: 90.0,
            testsCompleted: 1,
          ),
        ];
      }
      
      // Get reports for the user
      final reports = await _reportRepository.getReportsByUser(userId);
      
      // Get all categories
      final categories = await _categoryRepository.getAllCategories();
      
      // Calculate performance by category
      final Map<int, List<double>> categoryScores = {};
      
      for (final report in reports) {
        final testSet = await _testSetRepository.getTestSetById(report.testSetId);
        
        if (testSet != null) {
          final categoryId = testSet.categoryId;
          final score = report.percentage ?? 0.0;
          
          if (categoryScores.containsKey(categoryId)) {
            categoryScores[categoryId]!.add(score);
          } else {
            categoryScores[categoryId] = [score];
          }
        }
      }
      
      // Convert to CategoryPerformance objects
      final categoryPerformance = <CategoryPerformance>[];
      
      for (final category in categories) {
        if (categoryScores.containsKey(category.id)) {
          final scores = categoryScores[category.id]!;
          final averageScore = scores.reduce((a, b) => a + b) / scores.length;
          
          categoryPerformance.add(CategoryPerformance(
            categoryId: category.id,
            categoryName: category.name,
            averageScore: averageScore,
            testsCompleted: scores.length,
          ));
        }
      }
      
      // Sort by average score (descending)
      categoryPerformance.sort((a, b) => b.averageScore.compareTo(a.averageScore));
      
      return categoryPerformance;
    } catch (e) {
      print('Error getting category performance: $e');
      rethrow;
    }
  }
  
  // Get skill performance for the current user
  Future<List<SkillPerformance>> getSkillPerformance() async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }
      
      // In a real app, we would analyze the user's performance in different skill areas
      // For now, we'll return mock data
      return [
        SkillPerformance(skillName: 'Logical Reasoning', score: 85.0),
        SkillPerformance(skillName: 'Verbal Ability', score: 80.0),
        SkillPerformance(skillName: 'Quantitative Aptitude', score: 70.0),
        SkillPerformance(skillName: 'Data Interpretation', score: 75.0),
        SkillPerformance(skillName: 'General Knowledge', score: 65.0),
      ];
    } catch (e) {
      print('Error getting skill performance: $e');
      rethrow;
    }
  }
  
  // Get performance trend for the current user
  Future<Map<String, dynamic>> getPerformanceTrend() async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }
      
      // Get performance data
      final performanceData = await getPerformanceData();
      
      if (performanceData.isEmpty) {
        return {
          'trend': 'stable',
          'improvement': 0.0,
        };
      }
      
      // Calculate trend
      if (performanceData.length < 2) {
        return {
          'trend': 'stable',
          'improvement': 0.0,
        };
      }
      
      // Get first and last scores
      final firstScore = performanceData.first.score;
      final lastScore = performanceData.last.score;
      
      // Calculate improvement
      final improvement = lastScore - firstScore;
      
      // Determine trend
      String trend;
      if (improvement >= 5.0) {
        trend = 'improving';
      } else if (improvement <= -5.0) {
        trend = 'declining';
      } else {
        trend = 'stable';
      }
      
      return {
        'trend': trend,
        'improvement': improvement,
      };
    } catch (e) {
      print('Error getting performance trend: $e');
      rethrow;
    }
  }
  
  // Get test completion rate by day of week
  Future<Map<String, int>> getCompletionRateByDayOfWeek() async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }
      
      // Get performance data
      final performanceData = await getPerformanceData();
      
      // Initialize counts for each day of week
      final Map<String, int> completionRates = {
        'Monday': 0,
        'Tuesday': 0,
        'Wednesday': 0,
        'Thursday': 0,
        'Friday': 0,
        'Saturday': 0,
        'Sunday': 0,
      };
      
      // Count tests completed on each day of week
      for (final data in performanceData) {
        final dayOfWeek = _getDayOfWeek(data.date.weekday);
        completionRates[dayOfWeek] = (completionRates[dayOfWeek] ?? 0) + 1;
      }
      
      return completionRates;
    } catch (e) {
      print('Error getting completion rate by day of week: $e');
      rethrow;
    }
  }
  
  // Helper method to get day of week name
  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }
}
