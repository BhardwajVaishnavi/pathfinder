import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart'; // Removed for build
import 'utils/utils.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/simple_login_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/test_registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_completion_screen.dart';
import 'services/services.dart';
import 'scripts/db_migration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize services with error handling and timeouts for mobile
    final preferencesManager = PreferencesManager();
    await preferencesManager.init().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print('PreferencesManager initialization timeout - using defaults');
      },
    );

    // Initialize multi-user auth service with timeout
    final authService = MultiUserAuthService();
    await authService.initialize().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print('MultiUserAuthService initialization timeout - using defaults');
      },
    );

    // Initialize database service only if not on mobile or with very short timeout
    if (!kIsWeb) {
      try {
        final databaseService = DatabaseService();
        await databaseService.connect().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            print('Database connection timeout - app will work offline');
          },
        );

        // Run database migration with very short timeout
        final databaseMigration = DatabaseMigration();
        await databaseMigration.migrate().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            print('Database migration timeout - using existing schema');
          },
        );
      } catch (e) {
        print('Database initialization failed: $e - app will work offline');
      }
    }

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        print('Orientation setting timeout - using default orientations');
      },
    );
  } catch (e) {
    print('Initialization error: $e - starting app with minimal configuration');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>(
          create: (_) => DatabaseService(),
        ),
        Provider<MultiUserAuthService>(
          create: (_) => MultiUserAuthService(),
        ),
        Provider<PreferencesManager>(
          create: (_) => PreferencesManager(),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            background: AppColors.background,
            error: AppColors.error,
          ),
          // textTheme: GoogleFonts.poppinsTextTheme(), // Removed for build
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingM,
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const SimpleLoginScreen(),
          '/login_complex': (context) => const LoginScreen(),
          '/register': (context) => const RoleSelectionScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile_completion': (context) => const ProfileCompletionScreen(),
          '/test_registration': (context) => const TestRegistrationScreen(),
        }
      ),
    );
  }
}
