import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'achievements_screen.dart';
import 'analytics_screen.dart';
import 'leaderboard_screen.dart';
import 'notifications_screen.dart';
import 'test/test_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final RecommendationService _recommendationService = RecommendationService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  String _errorMessage = '';

  // Performance insights
  Map<String, dynamic> _insights = {};

  // Recommended tests
  List<TestSet> _recommendedTests = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Initialize auth service
      await _authService.initialize();

      // Load performance insights
      _insights = await _recommendationService.getPerformanceInsights();

      // Load recommended tests
      _recommendedTests = await _recommendationService.getRecommendedTests();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load dashboard data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            tooltip: 'Achievements',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AchievementsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: 'Leaderboard',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading dashboard...')
          : _errorMessage.isNotEmpty
              ? ErrorMessage(
                  message: _errorMessage,
                  onRetry: _loadData,
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeSection(),
                        const SizedBox(height: AppDimensions.paddingL),
                        _buildPerformanceOverview(),
                        const SizedBox(height: AppDimensions.paddingM),
                        _buildAnalyticsButton(),
                        const SizedBox(height: AppDimensions.paddingL),
                        _buildRecommendedTests(),
                        const SizedBox(height: AppDimensions.paddingL),
                        _buildStrengthsAndWeaknesses(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${_authService.currentUserName ?? 'User'}!',
              style: AppTextStyles.headline2,
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              'Track your progress and get personalized test recommendations.',
              style: AppTextStyles.bodyText1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceOverview() {
    final totalTests = _insights['totalTests'] ?? 0;
    final averageScore = _insights['averageScore'] ?? 0.0;
    final highestScore = _insights['highestScore'] ?? 0.0;
    final recentTrend = _insights['recentTrend'] ?? 'stable';

    IconData trendIcon;
    Color trendColor;

    switch (recentTrend) {
      case 'improving':
        trendIcon = Icons.trending_up;
        trendColor = AppColors.success;
        break;
      case 'declining':
        trendIcon = Icons.trending_down;
        trendColor = AppColors.error;
        break;
      default:
        trendIcon = Icons.trending_flat;
        trendColor = AppColors.warning;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
          style: AppTextStyles.headline3,
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Tests Taken',
                '$totalTests',
                Icons.assignment,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: _buildStatCard(
                'Average Score',
                '${averageScore.toStringAsFixed(1)}%',
                Icons.analytics,
                AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Highest Score',
                '${highestScore.toStringAsFixed(1)}%',
                Icons.emoji_events,
                AppColors.success,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: _buildStatCard(
                'Recent Trend',
                recentTrend.capitalize(),
                trendIcon,
                trendColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Text(
                  title,
                  style: AppTextStyles.subtitle2,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              value,
              style: AppTextStyles.headline3.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Tests',
          style: AppTextStyles.headline3,
        ),
        const SizedBox(height: AppDimensions.paddingM),
        _recommendedTests.isEmpty
            ? const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.paddingL),
                  child: Text(
                    'No recommended tests available. Complete more tests to get personalized recommendations.',
                    style: AppTextStyles.bodyText1,
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recommendedTests.length,
                itemBuilder: (context, index) {
                  final testSet = _recommendedTests[index];
                  return _buildTestCard(testSet);
                },
              ),
      ],
    );
  }

  Widget _buildTestCard(TestSet testSet) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TestDetailsScreen(testSet: testSet),
          ),
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                testSet.title,
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                testSet.description ?? 'No description available',
                style: AppTextStyles.bodyText2,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.timer,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppDimensions.paddingXS),
                      Text(
                        '${testSet.timeLimit ?? 60} min',
                        style: AppTextStyles.bodyText2,
                      ),
                    ],
                  ),
                  CustomButton(
                    text: 'Start Test',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TestDetailsScreen(testSet: testSet),
                      ),
                    ),
                    icon: Icons.play_arrow,
                    type: ButtonType.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsButton() {
    return Center(
      child: CustomButton(
        text: 'View Detailed Analytics',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
          );
        },
        icon: Icons.bar_chart,
        type: ButtonType.primary,
        width: double.infinity,
      ),
    );
  }

  Widget _buildStrengthsAndWeaknesses() {
    final strengths = _insights['strengths'] as List<dynamic>? ?? [];
    final areasForImprovement = _insights['areasForImprovement'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Strengths & Areas for Improvement',
          style: AppTextStyles.headline3,
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildStrengthsCard(strengths),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: _buildWeaknessesCard(areasForImprovement),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStrengthsCard(List<dynamic> strengths) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Text(
                  'Strengths',
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            strengths.isEmpty
                ? const Text(
                    'Complete more tests to identify your strengths.',
                    style: AppTextStyles.bodyText2,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: strengths
                        .map((strength) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppDimensions.paddingS,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                    size: 16,
                                  ),
                                  const SizedBox(width: AppDimensions.paddingS),
                                  Expanded(
                                    child: Text(
                                      strength.toString(),
                                      style: AppTextStyles.bodyText2,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeaknessesCard(List<dynamic> weaknesses) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Text(
                  'Areas to Improve',
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            weaknesses.isEmpty
                ? const Text(
                    'Complete more tests to identify areas for improvement.',
                    style: AppTextStyles.bodyText2,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: weaknesses
                        .map((weakness) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppDimensions.paddingS,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.priority_high,
                                    color: AppColors.warning,
                                    size: 16,
                                  ),
                                  const SizedBox(width: AppDimensions.paddingS),
                                  Expanded(
                                    child: Text(
                                      weakness.toString(),
                                      style: AppTextStyles.bodyText2,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
