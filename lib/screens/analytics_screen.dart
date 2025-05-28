import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'achievements_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  final AuthService _authService = AuthService();
  final AchievementService _achievementService = AchievementService();

  bool _isLoading = true;
  String _errorMessage = '';

  // Analytics data
  List<PerformanceData> _performanceData = [];
  List<CategoryPerformance> _categoryPerformance = [];
  List<SkillPerformance> _skillPerformance = [];
  Map<String, dynamic> _performanceTrend = {};
  Map<String, int> _completionRateByDayOfWeek = {};

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
    _unlockAnalyticsAchievement();
  }

  Future<void> _unlockAnalyticsAchievement() async {
    try {
      final achievement = await _achievementService.unlockAchievement('analytics_guru');
      if (achievement != null) {
        // Show a snackbar to notify the user
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Achievement Unlocked: ${achievement.title}'),
              backgroundColor: AppColors.success,
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                  );
                },
              ),
            ),
          );
        });

        // Update badge progress
        await _achievementService.updateBadgeProgress('analytics_master', 1);
      }
    } catch (e) {
      print('Error unlocking analytics achievement: $e');
    }
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load analytics data
      _performanceData = await _analyticsService.getPerformanceData();
      _categoryPerformance = await _analyticsService.getCategoryPerformance();
      _skillPerformance = await _analyticsService.getSkillPerformance();
      _performanceTrend = await _analyticsService.getPerformanceTrend();
      _completionRateByDayOfWeek = await _analyticsService.getCompletionRateByDayOfWeek();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load analytics data: ${e.toString()}';
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
        title: const Text('Analytics'),
        centerTitle: true,
        actions: [
          ShareButton(
            type: ShareType.analytics,
            data: {
              'totalTests': _performanceData.length,
              'averageScore': _performanceData.isEmpty
                  ? 0.0
                  : _performanceData.map((d) => d.score).reduce((a, b) => a + b) / _performanceData.length,
              'highestScore': _performanceData.isEmpty
                  ? 0.0
                  : _performanceData.map((d) => d.score).reduce((a, b) => a > b ? a : b),
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading analytics...')
          : _errorMessage.isNotEmpty
              ? ErrorMessage(
                  message: _errorMessage,
                  onRetry: _loadAnalyticsData,
                )
              : RefreshIndicator(
                  onRefresh: _loadAnalyticsData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeSection(),
                        const SizedBox(height: AppDimensions.paddingL),
                        _buildPerformanceTrendSection(),
                        const SizedBox(height: AppDimensions.paddingL),
                        _buildPerformanceChartSection(),
                        const SizedBox(height: AppDimensions.paddingL),
                        _buildCategoryPerformanceSection(),
                        const SizedBox(height: AppDimensions.paddingL),
                        _buildSkillPerformanceSection(),
                        const SizedBox(height: AppDimensions.paddingL),
                        _buildCompletionRateSection(),
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
              'Analytics Dashboard',
              style: AppTextStyles.headline2,
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              'Track your performance and identify areas for improvement.',
              style: AppTextStyles.bodyText1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTrendSection() {
    final trend = _performanceTrend['trend'] ?? 'stable';
    final improvement = _performanceTrend['improvement'] ?? 0.0;

    IconData trendIcon;
    Color trendColor;
    String trendText;

    switch (trend) {
      case 'improving':
        trendIcon = Icons.trending_up;
        trendColor = AppColors.success;
        trendText = 'Your performance is improving! Keep up the good work.';
        break;
      case 'declining':
        trendIcon = Icons.trending_down;
        trendColor = AppColors.error;
        trendText = 'Your performance is declining. Focus on areas for improvement.';
        break;
      default:
        trendIcon = Icons.trending_flat;
        trendColor = AppColors.warning;
        trendText = 'Your performance is stable. Try to challenge yourself more.';
    }

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
              'Performance Trend',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Row(
              children: [
                Icon(
                  trendIcon,
                  color: trendColor,
                  size: 32,
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        improvement >= 0
                            ? '+${improvement.toStringAsFixed(1)}%'
                            : '${improvement.toStringAsFixed(1)}%',
                        style: AppTextStyles.headline3.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingXS),
                      Text(
                        trendText,
                        style: AppTextStyles.bodyText2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChartSection() {
    if (_performanceData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingL),
          child: Text(
            'No performance data available. Complete more tests to see your progress over time.',
            style: AppTextStyles.bodyText1,
          ),
        ),
      );
    }

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
              'Performance Over Time',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < _performanceData.length) {
                            final date = _performanceData[value.toInt()].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(_performanceData.length, (index) {
                        return FlSpot(index.toDouble(), _performanceData[index].score);
                      }),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: 100,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            const Text(
              'This chart shows your test scores over time. A higher score indicates better performance.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPerformanceSection() {
    if (_categoryPerformance.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingL),
          child: Text(
            'No category performance data available. Complete tests in different categories to see your performance by category.',
            style: AppTextStyles.bodyText1,
          ),
        ),
      );
    }

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
              'Performance by Category',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${_categoryPerformance[groupIndex].categoryName}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '${rod.toY.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < _categoryPerformance.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _categoryPerformance[value.toInt()].categoryName.split(' ')[0],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(_categoryPerformance.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: _categoryPerformance[index].averageScore,
                          color: _getBarColor(_categoryPerformance[index].averageScore),
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            const Text(
              'This chart shows your average score in each category. Focus on categories with lower scores to improve your overall performance.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillPerformanceSection() {
    if (_skillPerformance.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingL),
          child: Text(
            'No skill performance data available. Complete more tests to see your performance by skill.',
            style: AppTextStyles.bodyText1,
          ),
        ),
      );
    }

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
              'Performance by Skill',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            SizedBox(
              height: 250,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  tickCount: 5,
                  ticksTextStyle: const TextStyle(color: Colors.transparent),
                  radarBorderData: const BorderSide(color: Colors.transparent),
                  gridBorderData: BorderSide(color: AppColors.divider, width: 1),
                  titlePositionPercentageOffset: 0.2,
                  titleTextStyle: AppTextStyles.caption,
                  getTitle: (index, angle) {
                    return RadarChartTitle(text: _skillPerformance[index].skillName);
                  },
                  dataSets: [
                    RadarDataSet(
                      fillColor: AppColors.primary.withOpacity(0.2),
                      borderColor: AppColors.primary,
                      borderWidth: 2,
                      entryRadius: 5,
                      dataEntries: List.generate(_skillPerformance.length, (index) {
                        return RadarEntry(value: _skillPerformance[index].score);
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            const Text(
              'This chart shows your performance in different skill areas. A larger area indicates better performance in that skill.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionRateSection() {
    if (_completionRateByDayOfWeek.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingL),
          child: Text(
            'No completion rate data available. Complete more tests to see your completion rate by day of week.',
            style: AppTextStyles.bodyText1,
          ),
        ),
      );
    }

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

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
              'Test Completion by Day of Week',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxCompletionRate() + 1,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${days[groupIndex]}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '${rod.toY.toInt()} tests',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[value.toInt()].substring(0, 3),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(days.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: _completionRateByDayOfWeek[days[index]]?.toDouble() ?? 0,
                          color: AppColors.info,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            const Text(
              'This chart shows the number of tests you have completed on each day of the week. Use this to identify patterns in your test-taking habits.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Color _getBarColor(double score) {
    if (score >= 80) {
      return AppColors.success;
    } else if (score >= 70) {
      return AppColors.info;
    } else if (score >= 60) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  int _getMaxCompletionRate() {
    if (_completionRateByDayOfWeek.isEmpty) return 0;

    return _completionRateByDayOfWeek.values.reduce((a, b) => a > b ? a : b);
  }
}
