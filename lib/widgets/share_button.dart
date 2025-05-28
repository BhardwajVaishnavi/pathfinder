import 'package:flutter/material.dart';
import '../models/models.dart';
import '../screens/achievements_screen.dart';
import '../services/achievement_service.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import 'custom_button.dart';

enum ShareType {
  achievement,
  testResult,
  badge,
  analytics,
  custom,
}

enum ShareButtonType {
  icon,
  primary,
  secondary,
  outline,
}

class ShareButton extends StatelessWidget {
  final ShareType type;
  final dynamic data;
  final String? customMessage;
  final GlobalKey? widgetKey;
  final IconData? icon;
  final String? text;
  final ShareButtonType buttonType;
  final ButtonType? customButtonType;

  const ShareButton({
    Key? key,
    required this.type,
    this.data,
    this.customMessage,
    this.widgetKey,
    this.icon = Icons.share,
    this.text,
    this.buttonType = ShareButtonType.icon,
    this.customButtonType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buttonType == ShareButtonType.icon
        ? IconButton(
            icon: Icon(icon),
            tooltip: 'Share',
            onPressed: () => _showShareOptions(context),
          )
        : CustomButton(
            text: text ?? 'Share',
            icon: icon,
            onPressed: () => _showShareOptions(context),
            type: customButtonType ?? ButtonType.primary,
          );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusL)),
      ),
      builder: (context) => _ShareOptionsSheet(
        type: type,
        data: data,
        customMessage: customMessage,
        widgetKey: widgetKey,
      ),
    );
  }
}

class _ShareOptionsSheet extends StatelessWidget {
  final ShareType type;
  final dynamic data;
  final String? customMessage;
  final GlobalKey? widgetKey;

  const _ShareOptionsSheet({
    Key? key,
    required this.type,
    this.data,
    this.customMessage,
    this.widgetKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share via',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSocialButton(
                context,
                'Twitter',
                Icons.flutter_dash, // Using flutter_dash as a placeholder for Twitter/X
                AppColors.info,
              ),
              _buildSocialButton(
                context,
                'Facebook',
                Icons.facebook,
                const Color(0xFF1877F2),
              ),
              _buildSocialButton(
                context,
                'WhatsApp',
                Icons.message,
                const Color(0xFF25D366),
              ),
              _buildSocialButton(
                context,
                'Telegram',
                Icons.telegram,
                const Color(0xFF0088CC),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingL),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Share with others',
              icon: Icons.share,
              onPressed: () => _share(context),
              type: ButtonType.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    String platform,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: () => _shareToSocialMedia(context, platform),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXS),
        Text(
          platform,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Future<void> _shareToSocialMedia(BuildContext context, String platform) async {
    final SharingService sharingService = SharingService();
    final AchievementService achievementService = AchievementService();
    final String text = await _getShareText();

    try {
      await sharingService.shareToSocialMedia(platform, text);

      // Unlock achievement for sharing on social media
      final achievement = await achievementService.unlockAchievement('social_butterfly');
      if (achievement != null) {
        // Show a snackbar to notify the user
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

        // Update badge progress
        await achievementService.updateBadgeProgress('social_media_guru', 1);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share to $platform: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _share(BuildContext context) async {
    final SharingService sharingService = SharingService();
    final AchievementService achievementService = AchievementService();

    try {
      if (widgetKey != null) {
        final text = await _getShareText();
        await sharingService.shareWidgetAsImage(widgetKey!, text);
      } else {
        await _shareBasedOnType(sharingService);
      }

      // Unlock achievement for sharing content
      final achievement = await achievementService.unlockAchievement('social_butterfly');
      if (achievement != null) {
        // Show a snackbar to notify the user
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

        // Update badge progress
        await achievementService.updateBadgeProgress('social_media_guru', 1);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to share content'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _shareBasedOnType(SharingService sharingService) async {
    switch (type) {
      case ShareType.achievement:
        if (data is Achievement) {
          await sharingService.shareAchievement(data);
        }
        break;
      case ShareType.testResult:
        if (data is Map<String, dynamic> &&
            data['report'] is Report &&
            data['testSet'] is TestSet) {
          await sharingService.shareTestResult(data['report'], data['testSet']);
        }
        break;
      case ShareType.badge:
        if (data is AchievementBadge) {
          await sharingService.shareBadge(data);
        }
        break;
      case ShareType.analytics:
        if (data is Map<String, dynamic>) {
          await sharingService.shareAnalytics(data);
        }
        break;
      case ShareType.custom:
        if (customMessage != null) {
          await sharingService.shareContent(customMessage!);
        }
        break;
    }
  }

  Future<String> _getShareText() async {
    switch (type) {
      case ShareType.achievement:
        if (data is Achievement) {
          final userName = AuthService().currentUserName ?? 'A user';
          return '$userName has unlocked the "${data.title}" achievement in Pathfinder!\n\n'
              '${data.description}\n\n'
              'Download Pathfinder and start your journey: https://pathfinder.app';
        }
        break;
      case ShareType.testResult:
        if (data is Map<String, dynamic> &&
            data['report'] is Report &&
            data['testSet'] is TestSet) {
          final report = data['report'] as Report;
          final testSet = data['testSet'] as TestSet;
          final userName = AuthService().currentUserName ?? 'A user';
          final score = report.score ?? 0;
          final percentage = report.percentage?.toStringAsFixed(1) ?? '0.0';

          return '$userName scored $score points ($percentage%) on "${testSet.title}" in Pathfinder!\n\n'
              'Download Pathfinder and test your skills: https://pathfinder.app';
        }
        break;
      case ShareType.badge:
        if (data is AchievementBadge) {
          final userName = AuthService().currentUserName ?? 'A user';
          return '$userName has reached level ${data.level} in the "${data.title}" badge in Pathfinder!\n\n'
              '${data.description}\n\n'
              'Download Pathfinder and start earning badges: https://pathfinder.app';
        }
        break;
      case ShareType.analytics:
        if (data is Map<String, dynamic>) {
          final userName = AuthService().currentUserName ?? 'A user';
          final totalTests = data['totalTests'] ?? 0;
          final averageScore = data['averageScore']?.toStringAsFixed(1) ?? '0.0';
          final highestScore = data['highestScore']?.toStringAsFixed(1) ?? '0.0';

          return '$userName has completed $totalTests tests with an average score of $averageScore% in Pathfinder!\n\n'
              'Highest score: $highestScore%\n\n'
              'Download Pathfinder and start your journey: https://pathfinder.app';
        }
        break;
      case ShareType.custom:
        if (customMessage != null) {
          return customMessage!;
        }
        break;
    }

    return 'Check out Pathfinder, the ultimate psychometric testing app! https://pathfinder.app';
  }
}
