import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import 'test_session_screen.dart';

class TestInstructionsScreen extends StatelessWidget {
  final TestSet testSet;
  final List<Question> questions;

  const TestInstructionsScreen({
    Key? key,
    required this.testSet,
    required this.questions,
  }) : super(key: key);

  void _startTest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TestSessionScreen(
          testSet: testSet,
          questions: questions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.testInstructions,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              testSet.title,
              style: AppTextStyles.headline2,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            if (testSet.description != null) ...[
              Text(
                testSet.description!,
                style: AppTextStyles.bodyText1,
              ),
              const SizedBox(height: AppDimensions.paddingL),
            ],

            // Instructions
            const Text(
              'Instructions',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            _buildInstructionItem(
              '1. Time Limit',
              'You have ${testSet.timeLimit ?? 60} minutes to complete this test. The timer will start once you begin the test.',
              Icons.timer,
            ),
            _buildInstructionItem(
              '2. Navigation',
              'You can navigate between questions using the Next and Previous buttons. You can also use the question navigator to jump to any question.',
              Icons.navigation,
            ),
            _buildInstructionItem(
              '3. Answering Questions',
              'Select the appropriate answer for multiple choice and true/false questions. Type your response for short answer questions.',
              Icons.question_answer,
            ),
            _buildInstructionItem(
              '4. Saving Answers',
              'Your answers are automatically saved as you navigate between questions.',
              Icons.save,
            ),
            _buildInstructionItem(
              '5. Submitting the Test',
              'You can submit the test at any time by clicking the Submit button. You will be asked to confirm before final submission.',
              Icons.check_circle,
            ),
            _buildInstructionItem(
              '6. Results',
              'Your results will be displayed immediately after submission, including your score and detailed analysis.',
              Icons.analytics,
            ),
            const SizedBox(height: AppDimensions.paddingXL),

            // Important notes
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.warning),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: AppDimensions.paddingS),
                      Text(
                        'Important Notes',
                        style: AppTextStyles.subtitle1,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  const Text(
                    '• Do not refresh the page or close the app during the test, as it may result in loss of progress.',
                    style: AppTextStyles.bodyText1,
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  const Text(
                    '• Ensure you have a stable internet connection before starting the test.',
                    style: AppTextStyles.bodyText1,
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  const Text(
                    '• Once submitted, you cannot retake the test or change your answers.',
                    style: AppTextStyles.bodyText1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),

            // Start test button
            CustomButton(
              text: AppStrings.startTest,
              onPressed: () => _startTest(context),
              isFullWidth: true,
              icon: Icons.play_arrow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.subtitle1,
                ),
                const SizedBox(height: AppDimensions.paddingXS),
                Text(
                  description,
                  style: AppTextStyles.bodyText1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
