import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../home_screen.dart';
import 'test_analysis_screen.dart';

class TestResultScreen extends StatelessWidget {
  final TestSet testSet;
  final List<Question> questions;
  final List<UserResponse> userResponses;
  final Report report;

  const TestResultScreen({
    Key? key,
    required this.testSet,
    required this.questions,
    required this.userResponses,
    required this.report,
  }) : super(key: key);

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _navigateToAnalysis(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TestAnalysisScreen(
          testSet: testSet,
          questions: questions,
          userResponses: userResponses,
          report: report,
        ),
      ),
    );
  }

  String _getResultMessage() {
    if (report.percentage != null) {
      if (report.percentage! >= 90) {
        return 'Excellent! You have demonstrated exceptional understanding of the subject matter.';
      } else if (report.percentage! >= 80) {
        return 'Great job! You have a strong grasp of the concepts.';
      } else if (report.percentage! >= 70) {
        return 'Good work! You have a solid understanding of most concepts.';
      } else if (report.percentage! >= 60) {
        return 'You passed! There are some areas where you can improve.';
      } else {
        return 'You need more practice. Review the concepts and try again.';
      }
    } else {
      return 'Test completed. Review your answers to improve.';
    }
  }

  Color _getResultColor() {
    if (report.percentage != null) {
      if (report.percentage! >= 70) {
        return AppColors.success;
      } else if (report.percentage! >= 60) {
        return AppColors.warning;
      } else {
        return AppColors.error;
      }
    } else {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultColor = _getResultColor();
    final totalQuestions = report.totalQuestions ?? questions.length;
    final correctAnswers = report.correctAnswers ?? 0;
    final incorrectAnswers = report.incorrectAnswers ?? 0;
    final skippedQuestions = totalQuestions - (correctAnswers + incorrectAnswers);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.testResults,
        showBackButton: false,
        actions: [
          ShareButton(
            type: ShareType.testResult,
            data: {
              'report': report,
              'testSet': testSet,
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Test title
            Text(
              testSet.title,
              style: AppTextStyles.headline2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              'Completed on ${report.createdAt != null ? DateFormatter.formatDateTime(report.createdAt!) : 'Unknown date'}',
              style: AppTextStyles.bodyText2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingXL),

            // Score circle
            CircularPercentIndicator(
              radius: 120,
              lineWidth: 15,
              percent: (report.percentage ?? 0) / 100,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(report.percentage ?? 0).toStringAsFixed(1)}%',
                    style: AppTextStyles.headline1.copyWith(
                      color: resultColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Score',
                    style: AppTextStyles.bodyText1,
                  ),
                ],
              ),
              progressColor: resultColor,
              backgroundColor: resultColor.withOpacity(0.2),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1000,
            ),
            const SizedBox(height: AppDimensions.paddingL),

            // Result message
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: resultColor),
              ),
              child: Text(
                _getResultMessage(),
                style: AppTextStyles.subtitle1.copyWith(
                  color: resultColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),

            // Score details
            const Text(
              'Score Details',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            if (report.score != null)
              _buildScoreDetail(
                'Score',
                '${report.score} / 100',
              ),
            _buildScoreDetail(
              'Questions Answered',
              '${correctAnswers + incorrectAnswers} / $totalQuestions',
            ),
            const SizedBox(height: AppDimensions.paddingL),

            // Performance breakdown
            const Text(
              'Performance Breakdown',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            _buildPerformanceBar(
              'Correct',
              correctAnswers,
              totalQuestions,
              AppColors.success,
            ),
            _buildPerformanceBar(
              'Incorrect',
              incorrectAnswers,
              totalQuestions,
              AppColors.error,
            ),
            _buildPerformanceBar(
              'Skipped',
              skippedQuestions,
              totalQuestions,
              AppColors.warning,
            ),
            const SizedBox(height: AppDimensions.paddingXL),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'View Analysis',
                    onPressed: () => _navigateToAnalysis(context),
                    icon: Icons.analytics,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: CustomButton(
                    text: 'Back to Home',
                    onPressed: () => _navigateToHome(context),
                    type: ButtonType.outline,
                    icon: Icons.home,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyText2,
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          Text(
            value,
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBar(
    String label,
    int value,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? value / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyText1,
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              Text(
                '$value / $total (${(percentage * 100).toStringAsFixed(1)}%)',
                style: AppTextStyles.bodyText2,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          LinearPercentIndicator(
            lineHeight: 10,
            percent: percentage,
            backgroundColor: color.withOpacity(0.2),
            progressColor: color,
            barRadius: const Radius.circular(5),
            animation: true,
            animationDuration: 1000,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
