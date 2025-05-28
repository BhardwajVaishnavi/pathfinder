import 'package:flutter/material.dart';
import '../services/achievement_service.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AchievementService _achievementService = AchievementService();

  bool _isLoading = true;
  String _errorMessage = '';

  // Achievement data
  List<Achievement> _achievements = [];
  List<AchievementBadge> _badges = [];
  int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAchievementData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAchievementData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load achievements, badges, and points
      _achievements = await _achievementService.getAchievements();
      _badges = await _achievementService.getBadges();
      _totalPoints = await _achievementService.getAchievementPoints();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load achievement data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Achievements'),
            Tab(text: 'Badges'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading achievements...')
          : _errorMessage.isNotEmpty
              ? ErrorMessage(
                  message: _errorMessage,
                  onRetry: _loadAchievementData,
                )
              : Column(
                  children: [
                    _buildPointsHeader(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAchievementsTab(),
                          _buildBadgesTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPointsHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.stars,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Text(
            'Total Achievement Points: $_totalPoints',
            style: AppTextStyles.subtitle1.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    final unlockedAchievements = _achievements.where((a) => a.isUnlocked).toList();
    final lockedAchievements = _achievements.where((a) => !a.isUnlocked).toList();

    return RefreshIndicator(
      onRefresh: _loadAchievementData,
      child: _achievements.isEmpty
          ? const Center(
              child: Text(
                'No achievements available',
                style: AppTextStyles.subtitle1,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              children: [
                if (unlockedAchievements.isNotEmpty) ...[
                  const Text(
                    'Unlocked Achievements',
                    style: AppTextStyles.headline3,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  ...unlockedAchievements.map((achievement) =>
                    _buildAchievementCard(achievement)
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                ],
                if (lockedAchievements.isNotEmpty) ...[
                  const Text(
                    'Locked Achievements',
                    style: AppTextStyles.headline3,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  ...lockedAchievements.map((achievement) =>
                    _buildAchievementCard(achievement)
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildBadgesTab() {
    return RefreshIndicator(
      onRefresh: _loadAchievementData,
      child: _badges.isEmpty
          ? const Center(
              child: Text(
                'No badges available',
                style: AppTextStyles.subtitle1,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              children: _badges.map((badge) =>
                _buildBadgeCard(badge)
              ).toList(),
            ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.textSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(achievement.iconName),
                color: isUnlocked ? AppColors.success : AppColors.textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: AppTextStyles.subtitle1.copyWith(
                      color: isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Text(
                    achievement.description,
                    style: AppTextStyles.bodyText2.copyWith(
                      color: isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  if (isUnlocked && achievement.unlockedAt != null) ...[
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(
                      'Unlocked on ${DateFormatter.formatDate(achievement.unlockedAt!)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingS,
                    vertical: AppDimensions.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: isUnlocked ? AppColors.success.withOpacity(0.1) : AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    '+${achievement.pointsAwarded}',
                    style: AppTextStyles.bodyText2.copyWith(
                      color: isUnlocked ? AppColors.success : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isUnlocked) ...[
                  const SizedBox(height: AppDimensions.paddingS),
                  ShareButton(
                    type: ShareType.achievement,
                    data: achievement,
                    icon: Icons.share,
                    buttonType: ShareButtonType.icon,
                  ),
                ] else ...[
                  const SizedBox(height: AppDimensions.paddingS),
                  const Icon(
                    Icons.lock,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCard(AchievementBadge badge) {
    final progress = badge.currentPoints / (badge.currentPoints + badge.pointsToNextLevel);
    final isMaxLevel = badge.level >= badge.maxLevel;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getBadgeLevelColor(badge.level).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        _getIconData(badge.iconName),
                        color: _getBadgeLevelColor(badge.level),
                        size: 32,
                      ),
                      if (badge.level > 0)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _getBadgeLevelColor(badge.level),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              badge.level.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${badge.title} (Level ${badge.level}/${badge.maxLevel})',
                        style: AppTextStyles.subtitle1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingXS),
                      Text(
                        badge.description,
                        style: AppTextStyles.bodyText2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            if (!isMaxLevel) ...[
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(_getBadgeLevelColor(badge.level)),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Text(
                    '${badge.currentPoints}/${badge.currentPoints + badge.pointsToNextLevel}',
                    style: AppTextStyles.bodyText2,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                '${badge.pointsToNextLevel} more to level ${badge.level + 1}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const Text(
                'Maximum level reached!',
                style: AppTextStyles.subtitle2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              ShareButton(
                type: ShareType.badge,
                data: badge,
                icon: Icons.share,
                buttonType: ShareButtonType.icon,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'assignment':
        return Icons.assignment;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'playlist_add_check':
        return Icons.playlist_add_check;
      case 'explore':
        return Icons.explore;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'speed':
        return Icons.speed;
      default:
        return Icons.star;
    }
  }

  Color _getBadgeLevelColor(int level) {
    switch (level) {
      case 0:
        return AppColors.textSecondary;
      case 1:
        return Colors.brown.shade300;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.amber;
      case 4:
        return AppColors.info;
      case 5:
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }
}
