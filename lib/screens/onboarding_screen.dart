import 'package:flutter/material.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'auth/login_screen.dart';
import 'auth/role_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: 'Welcome to Pathfinder',
      description: 'Discover your strengths and potential with our interactive psychometric and aptitude tests.',
      image: 'assets/images/onboarding1.png',
      icon: Icons.psychology,
    ),
    OnboardingItem(
      title: 'Personalized Tests',
      description: 'Get tests tailored to your educational background and experience level.',
      image: 'assets/images/onboarding2.png',
      icon: Icons.person_outline,
    ),
    OnboardingItem(
      title: 'Detailed Analysis',
      description: 'Receive comprehensive analysis of your performance and potential career paths.',
      image: 'assets/images/onboarding3.png',
      icon: Icons.analytics_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _navigateToLogin() async {
    // Mark app as not first time
    final preferencesManager = PreferencesManager();
    await preferencesManager.setFirstTime(false);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _navigateToRegister() async {
    // Mark app as not first time
    final preferencesManager = PreferencesManager();
    await preferencesManager.setFirstTime(false);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingItems.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingItems[index]);
                },
              ),
            ),
            _buildPageIndicator(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TODO: Replace with actual images when available
          Icon(
            item.icon,
            size: 120,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          Text(
            item.title,
            style: AppTextStyles.headline2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            item.description,
            style: AppTextStyles.bodyText1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _onboardingItems.length,
          (index) => _buildDot(index),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 16 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : AppColors.divider,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        children: [
          CustomButton(
            text: AppStrings.login,
            onPressed: () => _navigateToLogin(),
            isFullWidth: true,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          CustomButton(
            text: AppStrings.register,
            onPressed: () => _navigateToRegister(),
            type: ButtonType.outline,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String image;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
  });
}
