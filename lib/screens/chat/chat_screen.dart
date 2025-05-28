import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import 'chat_topic_screen.dart';
import 'create_topic_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ChatService _chatService = ChatService();
  final CategoryRepository _categoryRepository = CategoryRepository();

  bool _isLoading = true;
  String _errorMessage = '';

  // Chat data
  List<ChatTopic> _allTopics = [];
  List<Category> _categories = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadChatData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChatData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load categories and topics
      _categories = await _categoryRepository.getAllCategories();
      _allTopics = await _chatService.getTopics();

      // Initialize tab controller after loading categories
      _tabController = TabController(length: _categories.length + 1, vsync: this);
      _tabController.addListener(_handleTabChange);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load chat data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedCategoryId = _tabController.index == 0
            ? null
            : _categories[_tabController.index - 1].id;
      });
    }
  }

  List<ChatTopic> _getFilteredTopics() {
    if (_selectedCategoryId == null) {
      return _allTopics;
    } else {
      return _allTopics.where((topic) => topic.categoryId == _selectedCategoryId).toList();
    }
  }

  void _navigateToCreateTopic() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateTopicScreen(
          categories: _categories,
          onTopicCreated: (topic) {
            setState(() {
              _allTopics.add(topic);
            });
          },
        ),
      ),
    );
  }

  void _navigateToTopic(ChatTopic topic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatTopicScreen(topic: topic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        centerTitle: true,
        bottom: _isLoading || _categories.isEmpty
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  const Tab(text: 'All'),
                  ..._categories.map((category) => Tab(text: category.name)),
                ],
              ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading community discussions...')
          : _errorMessage.isNotEmpty
              ? ErrorMessage(
                  message: _errorMessage,
                  onRetry: _loadChatData,
                )
              : _buildTopicsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTopic,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTopicsList() {
    final filteredTopics = _getFilteredTopics();

    return RefreshIndicator(
      onRefresh: _loadChatData,
      child: filteredTopics.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.forum_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Text(
                    _selectedCategoryId == null
                        ? 'No topics yet. Be the first to start a discussion!'
                        : 'No topics in this category. Be the first to start a discussion!',
                    style: AppTextStyles.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  CustomButton(
                    text: 'Create Topic',
                    onPressed: _navigateToCreateTopic,
                    icon: Icons.add,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              itemCount: filteredTopics.length,
              itemBuilder: (context, index) {
                final topic = filteredTopics[index];
                return _buildTopicCard(topic);
              },
            ),
    );
  }

  Widget _buildTopicCard(ChatTopic topic) {
    final category = _categories.firstWhere(
      (c) => c.id == topic.categoryId,
      orElse: () => Category(id: 0, name: 'Unknown'),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: InkWell(
        onTap: () => _navigateToTopic(topic),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingS,
                      vertical: AppDimensions.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      category.name,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${topic.messageCount} ${topic.messageCount == 1 ? 'message' : 'messages'}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                topic.title,
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              Text(
                topic.description,
                style: AppTextStyles.bodyText2,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.paddingXS),
                  Text(
                    topic.creatorName,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.paddingXS),
                  Text(
                    _formatDate(topic.lastActivityAt),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormatter.formatDate(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
