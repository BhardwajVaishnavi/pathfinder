import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import 'auth_service.dart';
import 'test_service.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int pointsAwarded;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.pointsAwarded,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    int? pointsAwarded,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'pointsAwarded': pointsAwarded,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      iconName: map['iconName'],
      pointsAwarded: map['pointsAwarded'],
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedAt: map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt']) : null,
    );
  }
}

class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int level;
  final int maxLevel;
  final int currentPoints;
  final int pointsToNextLevel;

  AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.level,
    required this.maxLevel,
    required this.currentPoints,
    required this.pointsToNextLevel,
  });

  AchievementBadge copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    int? level,
    int? maxLevel,
    int? currentPoints,
    int? pointsToNextLevel,
  }) {
    return AchievementBadge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      level: level ?? this.level,
      maxLevel: maxLevel ?? this.maxLevel,
      currentPoints: currentPoints ?? this.currentPoints,
      pointsToNextLevel: pointsToNextLevel ?? this.pointsToNextLevel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'level': level,
      'maxLevel': maxLevel,
      'currentPoints': currentPoints,
      'pointsToNextLevel': pointsToNextLevel,
    };
  }

  factory AchievementBadge.fromMap(Map<String, dynamic> map) {
    return AchievementBadge(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      iconName: map['iconName'],
      level: map['level'],
      maxLevel: map['maxLevel'],
      currentPoints: map['currentPoints'],
      pointsToNextLevel: map['pointsToNextLevel'],
    );
  }
}

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  final AuthService _authService = AuthService();
  final ReportRepository _reportRepository = ReportRepository();
  final UserResponseRepository _userResponseRepository = UserResponseRepository();
  final TestSetRepository _testSetRepository = TestSetRepository();

  // Shared preferences keys
  static const String _achievementsKey = 'achievements';
  static const String _badgesKey = 'badges';
  static const String _pointsKey = 'achievement_points';

  factory AchievementService() {
    return _instance;
  }

  AchievementService._internal();

  // Get all achievements for the current user
  Future<List<Achievement>> getAchievements() async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      if (kIsWeb) {
        // Return mock data for web
        return [
          Achievement(
            id: 'first_test',
            title: 'First Steps',
            description: 'Complete your first test',
            iconName: 'assignment',
            pointsAwarded: 10,
            isUnlocked: true,
            unlockedAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
          Achievement(
            id: 'perfect_score',
            title: 'Perfect Score',
            description: 'Get a perfect score on any test',
            iconName: 'emoji_events',
            pointsAwarded: 50,
            isUnlocked: true,
            unlockedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          Achievement(
            id: 'five_tests',
            title: 'Getting Started',
            description: 'Complete 5 tests',
            iconName: 'playlist_add_check',
            pointsAwarded: 20,
            isUnlocked: false,
          ),
          Achievement(
            id: 'all_categories',
            title: 'Explorer',
            description: 'Complete a test in each category',
            iconName: 'explore',
            pointsAwarded: 30,
            isUnlocked: false,
          ),
          Achievement(
            id: 'three_day_streak',
            title: 'Consistent',
            description: 'Complete tests on 3 consecutive days',
            iconName: 'calendar_today',
            pointsAwarded: 25,
            isUnlocked: false,
          ),
        ];
      }

      // Get achievements from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = _authService.currentUserId!;
      final achievementsJson = prefs.getStringList('${_achievementsKey}_$userId') ?? [];

      if (achievementsJson.isEmpty) {
        // Initialize default achievements
        final defaultAchievements = _getDefaultAchievements();
        await _saveAchievements(defaultAchievements);
        return defaultAchievements;
      }

      // Parse achievements from JSON
      final achievements = achievementsJson.map((json) =>
        Achievement.fromMap(Map<String, dynamic>.from(
          Map<String, dynamic>.from(json as Map)
        ))
      ).toList();

      // Check for new achievements
      await _checkForNewAchievements(achievements);

      return achievements;
    } catch (e) {
      print('Error getting achievements: $e');
      rethrow;
    }
  }

  // Get all badges for the current user
  Future<List<AchievementBadge>> getBadges() async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      if (kIsWeb) {
        // Return mock data for web
        return [
          AchievementBadge(
            id: 'test_taker',
            title: 'Test Taker',
            description: 'Complete tests to level up this badge',
            iconName: 'assignment',
            level: 2,
            maxLevel: 5,
            currentPoints: 7,
            pointsToNextLevel: 10,
          ),
          AchievementBadge(
            id: 'high_scorer',
            title: 'High Scorer',
            description: 'Get high scores to level up this badge',
            iconName: 'emoji_events',
            level: 1,
            maxLevel: 5,
            currentPoints: 3,
            pointsToNextLevel: 5,
          ),
          AchievementBadge(
            id: 'quick_thinker',
            title: 'Quick Thinker',
            description: 'Complete tests quickly to level up this badge',
            iconName: 'speed',
            level: 0,
            maxLevel: 5,
            currentPoints: 2,
            pointsToNextLevel: 5,
          ),
        ];
      }

      // Get badges from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = _authService.currentUserId!;
      final badgesJson = prefs.getStringList('${_badgesKey}_$userId') ?? [];

      if (badgesJson.isEmpty) {
        // Initialize default badges
        final defaultBadges = _getDefaultBadges();
        await _saveBadges(defaultBadges);
        return defaultBadges;
      }

      // Parse badges from JSON
      final badges = badgesJson.map((json) =>
        AchievementBadge.fromMap(Map<String, dynamic>.from(
          Map<String, dynamic>.from(json as Map)
        ))
      ).toList();

      // Update badge progress
      await _updateBadgeProgress(badges);

      return badges;
    } catch (e) {
      print('Error getting badges: $e');
      rethrow;
    }
  }

  // Get total achievement points for the current user
  Future<int> getAchievementPoints() async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      if (kIsWeb) {
        // Return mock data for web
        return 85;
      }

      // Get points from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = _authService.currentUserId!;
      return prefs.getInt('${_pointsKey}_$userId') ?? 0;
    } catch (e) {
      print('Error getting achievement points: $e');
      rethrow;
    }
  }

  // Unlock specific achievements based on user actions
  Future<Achievement?> unlockAchievement(String achievementId) async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      // Get all achievements
      final achievements = await getAchievements();

      // Find the achievement
      final achievementIndex = achievements.indexWhere((a) => a.id == achievementId);
      if (achievementIndex == -1) {
        return null;
      }

      final achievement = achievements[achievementIndex];

      // If already unlocked, return null
      if (achievement.isUnlocked) {
        return null;
      }

      // Unlock the achievement
      final updatedAchievement = achievement.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

      achievements[achievementIndex] = updatedAchievement;

      // Save achievements
      await _saveAchievements(achievements);

      // Add points
      await _addAchievementPoints(achievement.pointsAwarded);

      return updatedAchievement;
    } catch (e) {
      print('Error unlocking achievement: $e');
      return null;
    }
  }

  // Update badge progress for specific badges
  Future<AchievementBadge?> updateBadgeProgress(String badgeId, int pointsToAdd) async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      // Get all badges
      final badges = await getBadges();

      // Find the badge
      final badgeIndex = badges.indexWhere((b) => b.id == badgeId);
      if (badgeIndex == -1) {
        return null;
      }

      final badge = badges[badgeIndex];

      // Update badge progress
      int newPoints = badge.currentPoints + pointsToAdd;
      int newLevel = badge.level;
      int newPointsToNext = badge.pointsToNextLevel - pointsToAdd;

      // Check if badge should level up
      while (newPointsToNext <= 0 && newLevel < badge.maxLevel) {
        newLevel++;
        newPointsToNext = (newLevel + 1) * 5 - newPoints;
      }

      // If max level reached, cap points
      if (newLevel >= badge.maxLevel) {
        newLevel = badge.maxLevel;
        newPointsToNext = 0;
      }

      // Update badge
      final updatedBadge = badge.copyWith(
        level: newLevel,
        currentPoints: newPoints,
        pointsToNextLevel: newPointsToNext,
      );

      badges[badgeIndex] = updatedBadge;

      // Save badges
      await _saveBadges(badges);

      return updatedBadge;
    } catch (e) {
      print('Error updating badge progress: $e');
      return null;
    }
  }

  // Check for new achievements based on user activity
  Future<void> _checkForNewAchievements(List<Achievement> achievements) async {
    final userId = _authService.currentUserId!;
    bool achievementsUpdated = false;

    // Get user reports
    final reports = await _reportRepository.getReportsByUser(userId);

    // Check for first test achievement
    final firstTestAchievement = achievements.firstWhere(
      (a) => a.id == 'first_test',
      orElse: () => Achievement(
        id: 'first_test',
        title: 'First Steps',
        description: 'Complete your first test',
        iconName: 'assignment',
        pointsAwarded: 10,
      ),
    );

    if (!firstTestAchievement.isUnlocked && reports.isNotEmpty) {
      achievements[achievements.indexOf(firstTestAchievement)] = firstTestAchievement.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      achievementsUpdated = true;
      await _addAchievementPoints(firstTestAchievement.pointsAwarded);
    }

    // Check for perfect score achievement
    final perfectScoreAchievement = achievements.firstWhere(
      (a) => a.id == 'perfect_score',
      orElse: () => Achievement(
        id: 'perfect_score',
        title: 'Perfect Score',
        description: 'Get a perfect score on any test',
        iconName: 'emoji_events',
        pointsAwarded: 50,
      ),
    );

    if (!perfectScoreAchievement.isUnlocked &&
        reports.any((r) => (r.percentage ?? 0) >= 100)) {
      achievements[achievements.indexOf(perfectScoreAchievement)] = perfectScoreAchievement.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      achievementsUpdated = true;
      await _addAchievementPoints(perfectScoreAchievement.pointsAwarded);
    }

    // Check for five tests achievement
    final fiveTestsAchievement = achievements.firstWhere(
      (a) => a.id == 'five_tests',
      orElse: () => Achievement(
        id: 'five_tests',
        title: 'Getting Started',
        description: 'Complete 5 tests',
        iconName: 'playlist_add_check',
        pointsAwarded: 20,
      ),
    );

    if (!fiveTestsAchievement.isUnlocked && reports.length >= 5) {
      achievements[achievements.indexOf(fiveTestsAchievement)] = fiveTestsAchievement.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      achievementsUpdated = true;
      await _addAchievementPoints(fiveTestsAchievement.pointsAwarded);
    }

    // Check for speed demon achievement
    final speedDemonAchievement = achievements.firstWhere(
      (a) => a.id == 'speed_demon',
      orElse: () => Achievement(
        id: 'speed_demon',
        title: 'Speed Demon',
        description: 'Complete a test in less than half the allotted time',
        iconName: 'speed',
        pointsAwarded: 35,
      ),
    );

    // Get user responses to check completion time
    if (!speedDemonAchievement.isUnlocked && reports.isNotEmpty) {
      for (final report in reports) {
        final testSet = await _testSetRepository.getTestSetById(report.testSetId);
        if (testSet != null) {
          final timeLimit = testSet.timeLimit ?? 60; // Default 60 minutes
          final responses = await _userResponseRepository.getUserResponsesByTestSet(userId, report.testSetId);

          if (responses.isNotEmpty) {
            // Calculate total time taken in minutes
            final totalResponseTime = responses.fold<int>(0, (sum, response) => sum + (response.responseTime ?? 0));
            final minutesTaken = totalResponseTime / 60000; // Convert milliseconds to minutes

            if (minutesTaken < timeLimit / 2) {
              achievements[achievements.indexOf(speedDemonAchievement)] = speedDemonAchievement.copyWith(
                isUnlocked: true,
                unlockedAt: DateTime.now(),
              );
              achievementsUpdated = true;
              await _addAchievementPoints(speedDemonAchievement.pointsAwarded);
              break;
            }
          }
        }
      }
    }

    // Check for analytics guru achievement
    final analyticsGuruAchievement = achievements.firstWhere(
      (a) => a.id == 'analytics_guru',
      orElse: () => Achievement(
        id: 'analytics_guru',
        title: 'Analytics Guru',
        description: 'View your detailed analytics',
        iconName: 'bar_chart',
        pointsAwarded: 5,
      ),
    );

    // This would normally be triggered when the user views the analytics screen
    // For demo purposes, we'll unlock it if the user has completed at least one test
    if (!analyticsGuruAchievement.isUnlocked && reports.isNotEmpty) {
      achievements[achievements.indexOf(analyticsGuruAchievement)] = analyticsGuruAchievement.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      achievementsUpdated = true;
      await _addAchievementPoints(analyticsGuruAchievement.pointsAwarded);
    }

    // Check for perfect streak achievement
    final perfectStreakAchievement = achievements.firstWhere(
      (a) => a.id == 'perfect_streak',
      orElse: () => Achievement(
        id: 'perfect_streak',
        title: 'Perfect Streak',
        description: 'Get perfect scores on 3 consecutive tests',
        iconName: 'auto_awesome',
        pointsAwarded: 100,
      ),
    );

    if (!perfectStreakAchievement.isUnlocked && reports.length >= 3) {
      // Sort reports by date (newest first)
      reports.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

      // Check the last 3 reports
      final lastThreeReports = reports.take(3).toList();
      final allPerfect = lastThreeReports.every((r) => (r.percentage ?? 0) >= 100);

      if (allPerfect) {
        achievements[achievements.indexOf(perfectStreakAchievement)] = perfectStreakAchievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        achievementsUpdated = true;
        await _addAchievementPoints(perfectStreakAchievement.pointsAwarded);
      }
    }

    if (achievementsUpdated) {
      await _saveAchievements(achievements);
    }
  }

  // Update badge progress based on user activity
  Future<void> _updateBadgeProgress(List<AchievementBadge> badges) async {
    final userId = _authService.currentUserId!;
    bool badgesUpdated = false;

    // Get user reports
    final reports = await _reportRepository.getReportsByUser(userId);

    // Update test taker badge
    final testTakerBadge = badges.firstWhere(
      (b) => b.id == 'test_taker',
      orElse: () => AchievementBadge(
        id: 'test_taker',
        title: 'Test Taker',
        description: 'Complete tests to level up this badge',
        iconName: 'assignment',
        level: 0,
        maxLevel: 5,
        currentPoints: 0,
        pointsToNextLevel: 5,
      ),
    );

    final testCount = reports.length;
    final testTakerPoints = testCount;
    final testTakerLevel = (testTakerPoints / 5).floor().clamp(0, testTakerBadge.maxLevel);
    final testTakerPointsToNext = testTakerLevel < testTakerBadge.maxLevel
        ? (testTakerLevel + 1) * 5 - testTakerPoints
        : 0;

    if (testTakerBadge.level != testTakerLevel ||
        testTakerBadge.currentPoints != testTakerPoints ||
        testTakerBadge.pointsToNextLevel != testTakerPointsToNext) {
      badges[badges.indexOf(testTakerBadge)] = testTakerBadge.copyWith(
        level: testTakerLevel,
        currentPoints: testTakerPoints,
        pointsToNextLevel: testTakerPointsToNext,
      );
      badgesUpdated = true;
    }

    // Update high scorer badge
    final highScorerBadge = badges.firstWhere(
      (b) => b.id == 'high_scorer',
      orElse: () => AchievementBadge(
        id: 'high_scorer',
        title: 'High Scorer',
        description: 'Get high scores to level up this badge',
        iconName: 'emoji_events',
        level: 0,
        maxLevel: 5,
        currentPoints: 0,
        pointsToNextLevel: 5,
      ),
    );

    final highScoreCount = reports.where((r) => (r.percentage ?? 0) >= 90).length;
    final highScorerPoints = highScoreCount;
    final highScorerLevel = (highScorerPoints / 5).floor().clamp(0, highScorerBadge.maxLevel);
    final highScorerPointsToNext = highScorerLevel < highScorerBadge.maxLevel
        ? (highScorerLevel + 1) * 5 - highScorerPoints
        : 0;

    if (highScorerBadge.level != highScorerLevel ||
        highScorerBadge.currentPoints != highScorerPoints ||
        highScorerBadge.pointsToNextLevel != highScorerPointsToNext) {
      badges[badges.indexOf(highScorerBadge)] = highScorerBadge.copyWith(
        level: highScorerLevel,
        currentPoints: highScorerPoints,
        pointsToNextLevel: highScorerPointsToNext,
      );
      badgesUpdated = true;
    }

    // Update quick thinker badge
    final quickThinkerBadge = badges.firstWhere(
      (b) => b.id == 'quick_thinker',
      orElse: () => AchievementBadge(
        id: 'quick_thinker',
        title: 'Quick Thinker',
        description: 'Complete tests quickly to level up this badge',
        iconName: 'speed',
        level: 0,
        maxLevel: 5,
        currentPoints: 0,
        pointsToNextLevel: 5,
      ),
    );

    // Count tests completed in less than 75% of allotted time
    int quickTestCount = 0;

    for (final report in reports) {
      final testSet = await _testSetRepository.getTestSetById(report.testSetId);
      if (testSet != null) {
        final timeLimit = testSet.timeLimit ?? 60; // Default 60 minutes
        final responses = await _userResponseRepository.getUserResponsesByTestSet(userId, report.testSetId);

        if (responses.isNotEmpty) {
          // Calculate total time taken in minutes
          final totalResponseTime = responses.fold<int>(0, (sum, response) => sum + (response.responseTime ?? 0));
          final minutesTaken = totalResponseTime / 60000; // Convert milliseconds to minutes

          if (minutesTaken < timeLimit * 0.75) {
            quickTestCount++;
          }
        }
      }
    }

    final quickThinkerPoints = quickTestCount;
    final quickThinkerLevel = (quickThinkerPoints / 5).floor().clamp(0, quickThinkerBadge.maxLevel);
    final quickThinkerPointsToNext = quickThinkerLevel < quickThinkerBadge.maxLevel
        ? (quickThinkerLevel + 1) * 5 - quickThinkerPoints
        : 0;

    if (quickThinkerBadge.level != quickThinkerLevel ||
        quickThinkerBadge.currentPoints != quickThinkerPoints ||
        quickThinkerBadge.pointsToNextLevel != quickThinkerPointsToNext) {
      badges[badges.indexOf(quickThinkerBadge)] = quickThinkerBadge.copyWith(
        level: quickThinkerLevel,
        currentPoints: quickThinkerPoints,
        pointsToNextLevel: quickThinkerPointsToNext,
      );
      badgesUpdated = true;
    }

    // Update category expert badge
    final categoryExpertBadge = badges.firstWhere(
      (b) => b.id == 'category_expert',
      orElse: () => AchievementBadge(
        id: 'category_expert',
        title: 'Category Expert',
        description: 'Master specific test categories',
        iconName: 'category',
        level: 0,
        maxLevel: 5,
        currentPoints: 0,
        pointsToNextLevel: 5,
      ),
    );

    // Count categories where user has scored 90% or higher
    final Map<int, double> categoryScores = {};

    for (final report in reports) {
      final testSet = await _testSetRepository.getTestSetById(report.testSetId);
      if (testSet != null) {
        final categoryId = testSet.categoryId;
        final score = report.percentage ?? 0.0;

        if (categoryScores.containsKey(categoryId)) {
          categoryScores[categoryId] = (categoryScores[categoryId]! + score) / 2;
        } else {
          categoryScores[categoryId] = score;
        }
      }
    }

    final expertCategoryCount = categoryScores.values.where((score) => score >= 90).length;

    final categoryExpertPoints = expertCategoryCount;
    final categoryExpertLevel = (categoryExpertPoints / 2).floor().clamp(0, categoryExpertBadge.maxLevel);
    final categoryExpertPointsToNext = categoryExpertLevel < categoryExpertBadge.maxLevel
        ? (categoryExpertLevel + 1) * 2 - categoryExpertPoints
        : 0;

    if (categoryExpertBadge.level != categoryExpertLevel ||
        categoryExpertBadge.currentPoints != categoryExpertPoints ||
        categoryExpertBadge.pointsToNextLevel != categoryExpertPointsToNext) {
      badges[badges.indexOf(categoryExpertBadge)] = categoryExpertBadge.copyWith(
        level: categoryExpertLevel,
        currentPoints: categoryExpertPoints,
        pointsToNextLevel: categoryExpertPointsToNext,
      );
      badgesUpdated = true;
    }

    // For demo purposes, we'll set the analytics master badge to level 1
    final analyticsMasterBadge = badges.firstWhere(
      (b) => b.id == 'analytics_master',
      orElse: () => AchievementBadge(
        id: 'analytics_master',
        title: 'Analytics Master',
        description: 'Use analytics to track and improve your performance',
        iconName: 'bar_chart',
        level: 0,
        maxLevel: 5,
        currentPoints: 0,
        pointsToNextLevel: 3,
      ),
    );

    if (reports.isNotEmpty && analyticsMasterBadge.level == 0) {
      badges[badges.indexOf(analyticsMasterBadge)] = analyticsMasterBadge.copyWith(
        level: 1,
        currentPoints: 3,
        pointsToNextLevel: 3,
      );
      badgesUpdated = true;
    }

    if (badgesUpdated) {
      await _saveBadges(badges);
    }
  }

  // Add achievement points to the user's total
  Future<void> _addAchievementPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _authService.currentUserId!;
    final currentPoints = prefs.getInt('${_pointsKey}_$userId') ?? 0;
    await prefs.setInt('${_pointsKey}_$userId', currentPoints + points);
  }

  // Save achievements to shared preferences
  Future<void> _saveAchievements(List<Achievement> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _authService.currentUserId!;
    final achievementsJson = achievements.map((a) => a.toMap()).toList();
    await prefs.setStringList('${_achievementsKey}_$userId',
      achievementsJson.map((a) => a.toString()).toList()
    );
  }

  // Save badges to shared preferences
  Future<void> _saveBadges(List<AchievementBadge> badges) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _authService.currentUserId!;
    final badgesJson = badges.map((b) => b.toMap()).toList();
    await prefs.setStringList('${_badgesKey}_$userId',
      badgesJson.map((b) => b.toString()).toList()
    );
  }

  // Get default achievements
  List<Achievement> _getDefaultAchievements() {
    return [
      Achievement(
        id: 'first_test',
        title: 'First Steps',
        description: 'Complete your first test',
        iconName: 'assignment',
        pointsAwarded: 10,
      ),
      Achievement(
        id: 'perfect_score',
        title: 'Perfect Score',
        description: 'Get a perfect score on any test',
        iconName: 'emoji_events',
        pointsAwarded: 50,
      ),
      Achievement(
        id: 'five_tests',
        title: 'Getting Started',
        description: 'Complete 5 tests',
        iconName: 'playlist_add_check',
        pointsAwarded: 20,
      ),
      Achievement(
        id: 'all_categories',
        title: 'Explorer',
        description: 'Complete a test in each category',
        iconName: 'explore',
        pointsAwarded: 30,
      ),
      Achievement(
        id: 'three_day_streak',
        title: 'Consistent',
        description: 'Complete tests on 3 consecutive days',
        iconName: 'calendar_today',
        pointsAwarded: 25,
      ),
      Achievement(
        id: 'speed_demon',
        title: 'Speed Demon',
        description: 'Complete a test in less than half the allotted time',
        iconName: 'speed',
        pointsAwarded: 35,
      ),
      Achievement(
        id: 'community_contributor',
        title: 'Community Contributor',
        description: 'Create your first topic in the community forum',
        iconName: 'forum',
        pointsAwarded: 15,
      ),
      Achievement(
        id: 'social_butterfly',
        title: 'Social Butterfly',
        description: 'Share a test result on social media',
        iconName: 'share',
        pointsAwarded: 10,
      ),
      Achievement(
        id: 'analytics_guru',
        title: 'Analytics Guru',
        description: 'View your detailed analytics',
        iconName: 'bar_chart',
        pointsAwarded: 5,
      ),
      Achievement(
        id: 'perfect_streak',
        title: 'Perfect Streak',
        description: 'Get perfect scores on 3 consecutive tests',
        iconName: 'auto_awesome',
        pointsAwarded: 100,
      ),
    ];
  }

  // Get default badges
  List<AchievementBadge> _getDefaultBadges() {
    return [
      AchievementBadge(
        id: 'test_taker',
        title: 'Test Taker',
        description: 'Complete tests to level up this badge',
        iconName: 'assignment',
        level: 0,
        maxLevel: 5,
        currentPoints: 0,
        pointsToNextLevel: 5,
      ),
      AchievementBadge(
        id: 'high_scorer',
        title: 'High Scorer',
        description: 'Get high scores to level up this badge',
        iconName: 'emoji_events',
        level: 0,
        maxLevel: 5,
        currentPoints: 0,
        pointsToNextLevel: 5,
      ),
      AchievementBadge(
        id: 'quick_thinker',
        title: 'Quick Thinker',
        description: 'Complete tests quickly to level up this badge',
        iconName: 'speed',
        level: 0,
        maxLevel: 5,
        currentPoints: 0,
        pointsToNextLevel: 5,
      ),
      AchievementBadge(
        id: 'community_star',
        title: 'Community Star',
        description: 'Create topics and post messages in the community',
        iconName: 'forum',
        level: 0,
        maxLevel: 5,
        currentPoints: 0,
        pointsToNextLevel: 5,
      ),
      AchievementBadge(
        id: 'social_media_guru',
        title: 'Social Media Guru',
        description: 'Share your achievements and results on social media',
        iconName: 'share',
        level: 0,
        maxLevel: 5,
        currentPoints: 0,
        pointsToNextLevel: 3,
      ),
      AchievementBadge(
        id: 'analytics_master',
        title: 'Analytics Master',
        description: 'Use analytics to track and improve your performance',
        iconName: 'bar_chart',
        level: 0,
        maxLevel: 5,
        currentPoints: 0,
        pointsToNextLevel: 3,
      ),
      AchievementBadge(
        id: 'category_expert',
        title: 'Category Expert',
        description: 'Master specific test categories',
        iconName: 'category',
        level: 0,
        maxLevel: 5,
        currentPoints: 0,
        pointsToNextLevel: 5,
      ),
    ];
  }
}
