import 'package:flutter/material.dart';

// App Colors
class AppColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color secondary = Color(0xFF2196F3);
  static const Color accent = Color(0xFFFF9800);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color divider = Color(0xFFE0E0E0);
}

// App Text Styles
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    // Color will be set dynamically in CustomButton based on button type
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}

// App Dimensions
class AppDimensions {
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 16.0;

  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;

  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;
}

// App Routes
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String testList = '/test-list';
  static const String testDetails = '/test-details';
  static const String testInstructions = '/test-instructions';
  static const String testSession = '/test-session';
  static const String testResults = '/test-results';
  static const String testAnalysis = '/test-analysis';
}

// App Strings
class AppStrings {
  static const String appName = 'Pathfinder Test App';
  static const String appDescription = 'Interactive psychometric and aptitude tests with detailed analysis';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String name = 'Name';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = 'Don\'t have an account?';
  static const String alreadyHaveAccount = 'Already have an account?';

  // Profile
  static const String profile = 'Profile';
  static const String educationLevel = 'Education Level';
  static const String updateProfile = 'Update Profile';

  // Tests
  static const String tests = 'Tests';
  static const String availableTests = 'Available Tests';
  static const String testInstructions = 'Test Instructions';
  static const String startTest = 'Start Test';
  static const String nextQuestion = 'Next Question';
  static const String previousQuestion = 'Previous Question';
  static const String submitTest = 'Submit Test';
  static const String testResults = 'Test Results';
  static const String testAnalysis = 'Test Analysis';

  // General
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String close = 'Close';
}

// App Assets
class AppAssets {
  static const String logoPath = 'assets/images/logo.png';
  static const String onboardingImage1 = 'assets/images/onboarding1.png';
  static const String onboardingImage2 = 'assets/images/onboarding2.png';
  static const String onboardingImage3 = 'assets/images/onboarding3.png';
  static const String profilePlaceholder = 'assets/images/profile_placeholder.png';
  static const String testIcon = 'assets/icons/test_icon.png';
  static const String resultIcon = 'assets/icons/result_icon.png';
  static const String analysisIcon = 'assets/icons/analysis_icon.png';
}
