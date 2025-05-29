import 'package:flutter/material.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'chat/chat_screen.dart';
import 'simple_dashboard_screen.dart';
import 'profile_screen.dart';
import 'test/test_list_screen.dart';
import 'results/results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SimpleDashboardScreen(),
    const TestListScreen(),
    const ResultsScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Tests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Results',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined),
            activeIcon: Icon(Icons.forum),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            const Text(
              'Welcome to Pathfinder!',
              style: AppTextStyles.headline2,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            const Text(
              'Discover your strengths and potential with our interactive psychometric and aptitude tests.',
              style: AppTextStyles.bodyText1,
            ),
            const SizedBox(height: AppDimensions.paddingXL),

            // Quick actions
            const Text(
              'Quick Actions',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            _buildQuickActionCard(
              context,
              title: 'Take a Test',
              description: 'Start a new test based on your education level',
              icon: Icons.assignment_outlined,
              color: AppColors.primary,
              onTap: () {
                // Navigate to test list screen
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TestListScreen()),
                );
              },
            ),
            const SizedBox(height: AppDimensions.paddingM),
            _buildQuickActionCard(
              context,
              title: 'View Results',
              description: 'Check your previous test results and analysis',
              icon: Icons.analytics_outlined,
              color: AppColors.secondary,
              onTap: () {
                // Navigate to results screen
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ResultsScreen()),
                );
              },
            ),
            const SizedBox(height: AppDimensions.paddingM),
            _buildQuickActionCard(
              context,
              title: 'Update Profile',
              description: 'Update your personal information and preferences',
              icon: Icons.person_outline,
              color: AppColors.accent,
              onTap: () {
                // Navigate to profile screen
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            const SizedBox(height: AppDimensions.paddingXL),

            // Information section
            const Text(
              'About Psychometric Tests',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            const Text(
              'Psychometric tests are designed to measure your cognitive abilities, aptitude, and personality traits. They help identify your strengths, weaknesses, and potential career paths that align with your abilities.',
              style: AppTextStyles.bodyText1,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            const Text(
              'Our tests are tailored to your educational background to provide the most relevant assessment and guidance for your future.',
              style: AppTextStyles.bodyText1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingL),
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
                      style: AppTextStyles.bodyText2,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
