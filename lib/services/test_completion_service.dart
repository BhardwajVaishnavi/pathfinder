import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Service to track test completion status and manage sequential test flow
class TestCompletionService {
  final MultiUserAuthService _authService = MultiUserAuthService();
  final TestService _testService = TestService();
  
  // Track completed tests per user (for web simulation)
  static final Map<int, Set<String>> _completedTests = {};
  
  /// Check if a specific test type has been completed by the current user
  Future<bool> isTestCompleted(String testType) async {
    if (!_authService.isLoggedIn) {
      return false;
    }
    
    final userId = _authService.currentUserId!;
    
    if (kIsWeb) {
      // For web simulation, use in-memory tracking
      return _completedTests[userId]?.contains(testType) ?? false;
    }
    
    // In production, check database for completed tests
    // This would query the reports table to see if user has completed this test type
    return false;
  }
  
  /// Mark a test as completed
  Future<void> markTestCompleted(String testType) async {
    if (!_authService.isLoggedIn) {
      return;
    }
    
    final userId = _authService.currentUserId!;
    
    if (kIsWeb) {
      // For web simulation, use in-memory tracking
      _completedTests[userId] ??= <String>{};
      _completedTests[userId]!.add(testType);
      print('✅ Test marked as completed: $testType for user $userId');
    }
    
    // In production, this would update the database
  }
  
  /// Get the next test that needs to be taken
  Future<TestSet?> getNextPendingTest() async {
    if (!_authService.isLoggedIn) {
      return null;
    }
    
    try {
      // Get available test sets for the user's education category
      final testSets = await _testService.getTestSetsForCategory(1); // Will be dynamic based on user
      
      // Check which tests are completed
      final aptitudeCompleted = await isTestCompleted('aptitude');
      final psychometricCompleted = await isTestCompleted('psychometric');
      
      // Find the next test to take
      for (final testSet in testSets) {
        if (testSet.title.toLowerCase().contains('aptitude') && !aptitudeCompleted) {
          return testSet;
        }
        if (testSet.title.toLowerCase().contains('psychometric') && !psychometricCompleted) {
          return testSet;
        }
      }
      
      return null; // All tests completed
    } catch (e) {
      print('Error getting next pending test: $e');
      return null;
    }
  }
  
  /// Get completion status for all test types
  Future<Map<String, bool>> getTestCompletionStatus() async {
    return {
      'aptitude': await isTestCompleted('aptitude'),
      'psychometric': await isTestCompleted('psychometric'),
    };
  }
  
  /// Check if all tests are completed
  Future<bool> areAllTestsCompleted() async {
    final status = await getTestCompletionStatus();
    return status.values.every((completed) => completed);
  }
  
  /// Get test type from test set
  String getTestTypeFromTestSet(TestSet testSet) {
    if (testSet.title.toLowerCase().contains('aptitude')) {
      return 'aptitude';
    } else if (testSet.title.toLowerCase().contains('psychometric')) {
      return 'psychometric';
    }
    return 'unknown';
  }
  
  /// Reset completion status (for testing purposes)
  void resetCompletionStatus() {
    if (!_authService.isLoggedIn) return;
    
    final userId = _authService.currentUserId!;
    _completedTests[userId]?.clear();
    print('🔄 Test completion status reset for user $userId');
  }
  
  /// Get available test sets excluding completed ones
  Future<List<TestSet>> getAvailableTestSets() async {
    if (!_authService.isLoggedIn) {
      return [];
    }
    
    try {
      // Get all test sets for the user's education category
      final allTestSets = await _testService.getTestSetsForCategory(1); // Will be dynamic
      final availableTestSets = <TestSet>[];
      
      for (final testSet in allTestSets) {
        final testType = getTestTypeFromTestSet(testSet);
        final isCompleted = await isTestCompleted(testType);
        
        if (!isCompleted) {
          availableTestSets.add(testSet);
        }
      }
      
      return availableTestSets;
    } catch (e) {
      print('Error getting available test sets: $e');
      return [];
    }
  }
}
