import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import 'student_registration_screen.dart';
import 'parent_registration_screen.dart';
import 'teacher_registration_screen.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  void _navigateToRegistration(BuildContext context, UserRole role) {
    Widget screen;
    switch (role) {
      case UserRole.student:
        screen = const StudentRegistrationScreen();
        break;
      case UserRole.parent:
        screen = const ParentRegistrationScreen();
        break;
      case UserRole.teacher:
        screen = const TeacherRegistrationScreen();
        break;
      default:
        screen = const StudentRegistrationScreen();
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add some top spacing for better mobile layout
              const SizedBox(height: AppDimensions.paddingXL),
              // App logo
              const Icon(
                Icons.psychology,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppDimensions.paddingM),

              // App name
              Text(
                AppStrings.appName,
                style: AppTextStyles.headline2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingS),

              // Subtitle
              Text(
                'AI-Powered Career Guidance Platform',
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingXL),

              // Role selection title
              Text(
                'Choose Your Role',
                style: AppTextStyles.headline3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Student role card
              _RoleCard(
                icon: Icons.school,
                title: 'Student',
                description: 'Take psychometric tests and get AI-powered career guidance',
                onTap: () => _navigateToRegistration(context, UserRole.student),
              ),
              const SizedBox(height: AppDimensions.paddingM),

              // Parent role card
              _RoleCard(
                icon: Icons.family_restroom,
                title: 'Parent',
                description: 'Monitor your child\'s progress and access detailed reports',
                onTap: () => _navigateToRegistration(context, UserRole.parent),
              ),
              const SizedBox(height: AppDimensions.paddingM),

              // Teacher role card
              _RoleCard(
                icon: Icons.person_outline,
                title: 'Teacher',
                description: 'Access student analytics and manage class performance',
                onTap: () => _navigateToRegistration(context, UserRole.teacher),
              ),
              const SizedBox(height: AppDimensions.paddingXL),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: AppTextStyles.bodyText2,
                  ),
                  TextButton(
                    onPressed: () => _navigateToLogin(context),
                    child: const Text('Login'),
                  ),
                ],
              ),

              // Add bottom spacing for mobile screens
              const SizedBox(height: AppDimensions.paddingXL),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                title,
                style: AppTextStyles.headline3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                description,
                style: AppTextStyles.bodyText2.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
