import 'package:flutter/material.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class ChatTopicScreen extends StatefulWidget {
  final ChatTopic topic;

  const ChatTopicScreen({
    Key? key,
    required this.topic,
  }) : super(key: key);

  @override
  State<ChatTopicScreen> createState() => _ChatTopicScreenState();
}

class _ChatTopicScreenState extends State<ChatTopicScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  String _errorMessage = '';
  List<ChatMessage> _messages = [];
  String? _replyToMessageId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      _messages = await _chatService.getMessages(widget.topic.id);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load messages: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });

      // Scroll to bottom after messages load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_replyToMessageId != null) {
        // Send reply
        await _chatService.addReply(
          topicId: widget.topic.id,
          messageId: _replyToMessageId!,
          message: message,
        );

        setState(() {
          _replyToMessageId = null;
        });
      } else {
        // Send new message
        await _chatService.addMessage(
          topicId: widget.topic.id,
          message: message,
        );
      }

      // Clear input and reload messages
      _messageController.clear();
      await _loadMessages();

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _likeMessage(String messageId) async {
    try {
      await _chatService.likeMessage(
        topicId: widget.topic.id,
        messageId: messageId,
      );

      await _loadMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to like message: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _likeReply(String messageId, String replyId) async {
    try {
      await _chatService.likeReply(
        topicId: widget.topic.id,
        messageId: messageId,
        replyId: replyId,
      );

      await _loadMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to like reply: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _replyToMessage(String messageId) {
    setState(() {
      _replyToMessageId = messageId;
    });

    // Focus the text field
    FocusScope.of(context).requestFocus(FocusNode());

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Replying to message'),
        action: SnackBarAction(
          label: 'Cancel',
          onPressed: () {
            setState(() {
              _replyToMessageId = null;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Topic info
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.topic.title,
                  style: AppTextStyles.headline3,
                ),
                const SizedBox(height: AppDimensions.paddingXS),
                Text(
                  widget.topic.description,
                  style: AppTextStyles.bodyText2,
                ),
                const SizedBox(height: AppDimensions.paddingS),
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppDimensions.paddingXS),
                    Text(
                      'Created by ${widget.topic.creatorName}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppDimensions.paddingXS),
                    Text(
                      DateFormatter.formatDate(widget.topic.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: _isLoading && _messages.isEmpty
                ? const LoadingIndicator(message: 'Loading messages...')
                : _errorMessage.isNotEmpty
                    ? ErrorMessage(
                        message: _errorMessage,
                        onRetry: _loadMessages,
                      )
                    : _messages.isEmpty
                        ? const Center(
                            child: Text(
                              'No messages yet. Be the first to post!',
                              style: AppTextStyles.subtitle1,
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(AppDimensions.paddingM),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              return _buildMessageCard(message);
                            },
                          ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: _replyToMessageId != null
                          ? 'Reply to message...'
                          : 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.paddingS,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(ChatMessage message) {
    final isCurrentUser = _authService.currentUserId == message.userId;
    final hasLiked = message.likes.contains(_authService.currentUserId.toString());

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      color: isCurrentUser ? AppColors.primary.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isCurrentUser ? AppColors.primary : AppColors.secondary,
                  radius: 16,
                  child: Text(
                    message.userName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Text(
                  message.userName,
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(message.timestamp),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              message.message,
              style: AppTextStyles.bodyText1,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Row(
              children: [
                InkWell(
                  onTap: () => _likeMessage(message.id),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingXS),
                    child: Row(
                      children: [
                        Icon(
                          hasLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: hasLiked ? AppColors.error : AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppDimensions.paddingXS),
                        Text(
                          message.likes.length.toString(),
                          style: AppTextStyles.caption.copyWith(
                            color: hasLiked ? AppColors.error : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                InkWell(
                  onTap: () => _replyToMessage(message.id),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingXS),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.reply,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppDimensions.paddingXS),
                        Text(
                          'Reply',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                ShareButton(
                  type: ShareType.custom,
                  customMessage: 'Check out this message from ${message.userName} in the Pathfinder community:\n\n"${message.message}"\n\nJoin the discussion: https://pathfinder.app',
                  icon: Icons.share,
                  buttonType: ShareButtonType.icon,
                ),
              ],
            ),

            // Replies
            if (message.replies.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.paddingM),
              const Divider(),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                'Replies',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              ...message.replies.map((reply) => _buildReplyCard(message.id, reply)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReplyCard(String messageId, ChatReply reply) {
    final isCurrentUser = _authService.currentUserId == reply.userId;
    final hasLiked = reply.likes.contains(_authService.currentUserId.toString());

    return Container(
      margin: const EdgeInsets.only(
        left: AppDimensions.paddingL,
        bottom: AppDimensions.paddingS,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.primary.withOpacity(0.05) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isCurrentUser ? AppColors.primary : AppColors.secondary,
                radius: 12,
                child: Text(
                  reply.userName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                reply.userName,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(reply.timestamp),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            reply.message,
            style: AppTextStyles.bodyText2,
          ),
          const SizedBox(height: AppDimensions.paddingS),
          InkWell(
            onTap: () => _likeReply(messageId, reply.id),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingXS),
              child: Row(
                children: [
                  Icon(
                    hasLiked ? Icons.favorite : Icons.favorite_border,
                    size: 14,
                    color: hasLiked ? AppColors.error : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.paddingXS),
                  Text(
                    reply.likes.length.toString(),
                    style: AppTextStyles.caption.copyWith(
                      color: hasLiked ? AppColors.error : AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
