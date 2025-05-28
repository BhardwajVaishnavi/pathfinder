import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/models.dart';
import '../repositories/repositories.dart';
import 'auth_service.dart';
import 'test_service.dart';

class RecommendationService {
  static final RecommendationService _instance = RecommendationService._internal();
  final ReportRepository _reportRepository = ReportRepository();
  final TestSetRepository _testSetRepository = TestSetRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final AuthService _authService = AuthService();
  final TestService _testService = TestService();
  
  factory RecommendationService() {
    return _instance;
  }
  
  RecommendationService._internal();
  
  // Get recommended tests for the current user
  Future<List<TestSet>> getRecommendedTests({int limit = 3}) async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }
      
      final userId = _authService.currentUserId!;
      final categoryId = _authService.currentUserCategoryId ?? 1;
      
      if (kIsWeb) {
        // Return mock data for web
        final allTestSets = await _testService.getTestSetsForCategory(categoryId);
        // Simulate recommendations by returning a subset of test sets
        return allTestSets.take(limit).toList();
      }
      
      // Get user's completed tests
      final reports = await _reportRepository.getReportsByUser(userId);
      
      // If user hasn't completed any tests, recommend tests from their category
      if (reports.isEmpty) {
        final testSets = await _testSetRepository.getTestSetsByCategory(categoryId);
        return testSets.take(limit).toList();
      }
      
      // Get test sets the user has already completed
      final completedTestSetIds = reports.map((r) => r.testSetId).toSet();
      
      // Get all test sets for the user's category
      final allTestSets = await _testSetRepository.getTestSetsByCategory(categoryId);
      
      // Filter out completed test sets
      final uncompletedTestSets = allTestSets
          .where((ts) => !completedTestSetIds.contains(ts.id))
          .toList();
      
      // If there are uncompleted test sets, recommend those first
      if (uncompletedTestSets.isNotEmpty) {
        return uncompletedTestSets.take(limit).toList();
      }
      
      // If all test sets in the user's category are completed, recommend test sets
      // from other categories based on performance
      
      // Calculate average performance by category
      final Map<int, double> categoryPerformance = {};
      
      for (final report in reports) {
        final testSet = await _testSetRepository.getTestSetById(report.testSetId);
        if (testSet != null) {
          final categoryId = testSet.categoryId;
          final performance = report.percentage ?? 0.0;
          
          if (categoryPerformance.containsKey(categoryId)) {
            categoryPerformance[categoryId] = (categoryPerformance[categoryId]! + performance) / 2;
          } else {
            categoryPerformance[categoryId] = performance;
          }
        }
      }
      
      // Get all categories
      final allCategories = await _categoryRepository.getAllCategories();
      
      // Sort categories by performance (ascending, so we recommend categories where the user needs improvement)
      final sortedCategories = allCategories
          .where((c) => categoryPerformance.containsKey(c.id))
          .toList()
        ..sort((a, b) => categoryPerformance[a.id]!.compareTo(categoryPerformance[b.id]!));
      
      // Add categories the user hasn't tried yet
      sortedCategories.addAll(
        allCategories.where((c) => !categoryPerformance.containsKey(c.id))
      );
      
      // Get test sets from categories where the user needs improvement
      final recommendedTestSets = <TestSet>[];
      
      for (final category in sortedCategories) {
        if (recommendedTestSets.length >= limit) break;
        
        final categoryTestSets = await _testSetRepository.getTestSetsByCategory(category.id);
        
        // Add test sets the user hasn't completed yet
        for (final testSet in categoryTestSets) {
          if (!completedTestSetIds.contains(testSet.id)) {
            recommendedTestSets.add(testSet);
            if (recommendedTestSets.length >= limit) break;
          }
        }
      }
      
      // If we still don't have enough recommendations, add test sets the user has completed
      // but with low scores
      if (recommendedTestSets.length < limit) {
        // Sort reports by score (ascending)
        reports.sort((a, b) => (a.score ?? 0).compareTo(b.score ?? 0));
        
        for (final report in reports) {
          if (recommendedTestSets.length >= limit) break;
          
          final testSet = await _testSetRepository.getTestSetById(report.testSetId);
          if (testSet != null && !recommendedTestSets.any((ts) => ts.id == testSet.id)) {
            recommendedTestSets.add(testSet);
          }
        }
      }
      
      return recommendedTestSets;
    } catch (e) {
      print('Error getting recommended tests: $e');
      rethrow;
    }
  }
  
  // Get performance insights for the current user
  Future<Map<String, dynamic>> getPerformanceInsights() async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }
      
      final userId = _authService.currentUserId!;
      
      if (kIsWeb) {
        // Return mock data for web
        return {
          'totalTests': 5,
          'averageScore': 75.0,
          'highestScore': 90.0,
          'lowestScore': 60.0,
          'recentTrend': 'improving', // 'improving', 'declining', or 'stable'
          'categoryPerformance': {
            '10th Fail': 80.0,
            '10th Pass': 75.0,
            '12th Fail': 70.0,
          },
          'strengths': ['Logical reasoning', 'Verbal ability'],
          'areasForImprovement': ['Mathematical aptitude', 'Spatial reasoning'],
        };
      }
      
      // Get user's completed tests
      final reports = await _reportRepository.getReportsByUser(userId);
      
      if (reports.isEmpty) {
        return {
          'totalTests': 0,
          'averageScore': 0.0,
          'highestScore': 0.0,
          'lowestScore': 0.0,
          'recentTrend': 'stable',
          'categoryPerformance': {},
          'strengths': [],
          'areasForImprovement': [],
        };
      }
      
      // Calculate basic statistics
      final totalTests = reports.length;
      final scores = reports.map((r) => r.score ?? 0).toList();
      final averageScore = scores.reduce((a, b) => a + b) / totalTests;
      final highestScore = scores.reduce((a, b) => a > b ? a : b);
      final lowestScore = scores.reduce((a, b) => a < b ? a : b);
      
      // Determine recent trend
      String recentTrend = 'stable';
      if (reports.length >= 3) {
        // Sort reports by date (newest first)
        reports.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
        
        final recentScores = reports.take(3).map((r) => r.score ?? 0).toList();
        final oldestScore = recentScores.last;
        final newestScore = recentScores.first;
        
        if (newestScore > oldestScore + 5) {
          recentTrend = 'improving';
        } else if (newestScore < oldestScore - 5) {
          recentTrend = 'declining';
        }
      }
      
      // Calculate performance by category
      final Map<String, double> categoryPerformance = {};
      
      for (final report in reports) {
        final testSet = await _testSetRepository.getTestSetById(report.testSetId);
        if (testSet != null) {
          final category = await _categoryRepository.getCategoryById(testSet.categoryId);
          if (category != null) {
            final categoryName = category.name;
            final performance = report.percentage ?? 0.0;
            
            if (categoryPerformance.containsKey(categoryName)) {
              categoryPerformance[categoryName] = (categoryPerformance[categoryName]! + performance) / 2;
            } else {
              categoryPerformance[categoryName] = performance;
            }
          }
        }
      }
      
      // Identify strengths and areas for improvement
      final strengths = <String>[];
      final areasForImprovement = <String>[];
      
      categoryPerformance.forEach((category, performance) {
        if (performance >= 80) {
          strengths.add(category);
        } else if (performance < 70) {
          areasForImprovement.add(category);
        }
      });
      
      return {
        'totalTests': totalTests,
        'averageScore': averageScore,
        'highestScore': highestScore,
        'lowestScore': lowestScore,
        'recentTrend': recentTrend,
        'categoryPerformance': categoryPerformance,
        'strengths': strengths,
        'areasForImprovement': areasForImprovement,
      };
    } catch (e) {
      print('Error getting performance insights: $e');
      rethrow;
    }
  }
}
