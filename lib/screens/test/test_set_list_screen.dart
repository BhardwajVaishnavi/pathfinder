import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../profile_completion_screen.dart';
import 'test_details_screen.dart';

class TestSetListScreen extends StatefulWidget {
  final Category category;

  const TestSetListScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<TestSetListScreen> createState() => _TestSetListScreenState();
}

class _TestSetListScreenState extends State<TestSetListScreen> {
  final TestService _testService = TestService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  List<TestSet> _testSets = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
  }

  void _checkProfileCompletion() {
    // Check if user profile is complete
    if (!_authService.isUserProfileComplete()) {
      // Show a dialog to inform the user
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Profile Incomplete'),
            content: const Text(
              'You need to complete your profile and upload identity proof before taking tests. '
              'This is required for verification purposes.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileCompletionScreen(),
                    ),
                  );
                },
                child: const Text('Complete Profile'),
              ),
            ],
          ),
        );
      });
    } else {
      _loadTestSets();
    }
  }

  Future<void> _loadTestSets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load test sets for the selected category using the test service
      _testSets = await _testService.getTestSetsForCategory(widget.category.id);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load tests: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToTestDetails(TestSet testSet) {
    // Check if user profile is complete before navigating
    if (!_authService.isUserProfileComplete()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Profile Incomplete'),
          content: const Text(
            'You need to complete your profile and upload identity proof before taking tests. '
            'This is required for verification purposes.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProfileCompletionScreen(),
                  ),
                );
              },
              child: const Text('Complete Profile'),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TestDetailsScreen(testSet: testSet),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading tests...')
          : _errorMessage.isNotEmpty
              ? ErrorMessage(
                  message: _errorMessage,
                  onRetry: _loadTestSets,
                )
              : _testSets.isEmpty
                  ? const Center(
                      child: Text(
                        'No tests available for this category',
                        style: AppTextStyles.subtitle1,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      itemCount: _testSets.length,
                      itemBuilder: (context, index) {
                        final testSet = _testSets[index];
                        return _buildTestSetCard(testSet);
                      },
                    ),
    );
  }

  Widget _buildTestSetCard(TestSet testSet) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: InkWell(
        onTap: () => _navigateToTestDetails(testSet),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          testSet.title,
                          style: AppTextStyles.subtitle1,
                        ),
                        if (testSet.timeLimit != null) ...[
                          const SizedBox(height: AppDimensions.paddingXS),
                          Text(
                            'Time Limit: ${testSet.timeLimit} minutes',
                            style: AppTextStyles.bodyText2,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (testSet.description != null) ...[
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  testSet.description!,
                  style: AppTextStyles.bodyText1,
                ),
              ],
              const SizedBox(height: AppDimensions.paddingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (testSet.passingScore != null)
                    Text(
                      'Passing Score: ${testSet.passingScore}%',
                      style: AppTextStyles.bodyText2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  CustomButton(
                    text: 'Start Test',
                    onPressed: () => _navigateToTestDetails(testSet),
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
}
