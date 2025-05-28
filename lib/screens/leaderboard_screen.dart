import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Leaderboard data
  List<Map<String, dynamic>> _weeklyLeaders = [];
  List<Map<String, dynamic>> _monthlyLeaders = [];
  List<Map<String, dynamic>> _allTimeLeaders = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLeaderboardData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadLeaderboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // In a real app, we would fetch this data from the server
      // For now, we'll use mock data
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Generate mock leaderboard data
      _weeklyLeaders = _generateMockLeaderboardData(10);
      _monthlyLeaders = _generateMockLeaderboardData(20);
      _allTimeLeaders = _generateMockLeaderboardData(50);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load leaderboard data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  List<Map<String, dynamic>> _generateMockLeaderboardData(int count) {
    final List<Map<String, dynamic>> leaders = [];
    
    // Add current user
    final currentUserName = _authService.currentUserName ?? 'You';
    final currentUserRank = 3 + (count ~/ 10); // Place user in top 3 for small lists, or top 30% for larger lists
    
    for (int i = 1; i <= count; i++) {
      if (i == currentUserRank) {
        leaders.add({
          'rank': i,
          'name': currentUserName,
          'score': 85 + (count - i),
          'isCurrentUser': true,
        });
      } else {
        leaders.add({
          'rank': i,
          'name': 'User ${i + 100}',
          'score': 90 + (count - i),
          'isCurrentUser': false,
        });
      }
    }
    
    return leaders;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'All Time'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading leaderboard...')
          : _errorMessage.isNotEmpty
              ? ErrorMessage(
                  message: _errorMessage,
                  onRetry: _loadLeaderboardData,
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLeaderboardTab(_weeklyLeaders),
                    _buildLeaderboardTab(_monthlyLeaders),
                    _buildLeaderboardTab(_allTimeLeaders),
                  ],
                ),
    );
  }
  
  Widget _buildLeaderboardTab(List<Map<String, dynamic>> leaders) {
    return RefreshIndicator(
      onRefresh: _loadLeaderboardData,
      child: leaders.isEmpty
          ? const Center(
              child: Text(
                'No leaderboard data available',
                style: AppTextStyles.subtitle1,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              itemCount: leaders.length + 1, // +1 for the header
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildLeaderboardHeader();
                }
                
                final leaderIndex = index - 1;
                final leader = leaders[leaderIndex];
                
                return _buildLeaderboardItem(
                  rank: leader['rank'],
                  name: leader['name'],
                  score: leader['score'],
                  isCurrentUser: leader['isCurrentUser'],
                );
              },
            ),
    );
  }
  
  Widget _buildLeaderboardHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.paddingM,
        left: AppDimensions.paddingM,
        right: AppDimensions.paddingM,
      ),
      child: Row(
        children: [
          const SizedBox(width: 50, child: Text('Rank', style: AppTextStyles.subtitle2)),
          const SizedBox(width: AppDimensions.paddingM),
          const Expanded(child: Text('Name', style: AppTextStyles.subtitle2)),
          const SizedBox(width: AppDimensions.paddingM),
          const SizedBox(width: 80, child: Text('Score', style: AppTextStyles.subtitle2)),
        ],
      ),
    );
  }
  
  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required int score,
    required bool isCurrentUser,
  }) {
    Color backgroundColor = Colors.transparent;
    Color textColor = AppColors.textPrimary;
    
    if (isCurrentUser) {
      backgroundColor = AppColors.primary.withOpacity(0.1);
      textColor = AppColors.primary;
    } else if (rank <= 3) {
      backgroundColor = AppColors.success.withOpacity(0.1);
      textColor = AppColors.success;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: isCurrentUser ? AppColors.primary : AppColors.divider,
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: _buildRankWidget(rank),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.bodyText1.copyWith(
                  color: textColor,
                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            SizedBox(
              width: 80,
              child: Text(
                score.toString(),
                style: AppTextStyles.bodyText1.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRankWidget(int rank) {
    if (rank > 3) {
      return Text(
        '#$rank',
        style: AppTextStyles.bodyText1.copyWith(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      );
    }
    
    IconData icon;
    Color color;
    
    switch (rank) {
      case 1:
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case 2:
        icon = Icons.emoji_events;
        color = Colors.grey.shade400;
        break;
      case 3:
        icon = Icons.emoji_events;
        color = Colors.brown.shade300;
        break;
      default:
        icon = Icons.emoji_events;
        color = AppColors.textSecondary;
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        Text(
          '#$rank',
          style: AppTextStyles.bodyText2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
