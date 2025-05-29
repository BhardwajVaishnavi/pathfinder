import 'package:flutter/material.dart';
import 'dart:async';
import '../services/services.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'profile_completion_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Navigate to the next screen after a delay
    Timer(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  Future<void> _navigateToNextScreen() async {
    try {
      // Check if user is already logged in
      final authService = MultiUserAuthService();
      await authService.initialize();

      // Check if first time using the app
      final preferencesManager = PreferencesManager();
      final isFirstTime = await preferencesManager.isFirstTime();

      if (!mounted) return;

      if (isFirstTime) {
        // First time using the app, show onboarding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      } else if (authService.isLoggedIn) {
        // User is logged in, go to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // User is not logged in, go to login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      print('Navigation error: $e - defaulting to login screen');
      if (!mounted) return;

      // Default to login screen if there's any error
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TODO: Replace with actual logo
              const Icon(
                Icons.psychology,
                size: 100,
                color: AppColors.surface,
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Text(
                AppStrings.appName,
                style: AppTextStyles.headline1.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                AppStrings.appDescription,
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppColors.surface.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              const LoadingIndicator(
                color: AppColors.surface,
                size: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
