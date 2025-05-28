import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'auth_service.dart';

class ChatMessage {
  final String id;
  final int userId;
  final String userName;
  final String message;
  final DateTime timestamp;
  final List<String> likes;
  final List<ChatReply> replies;
  
  ChatMessage({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.timestamp,
    this.likes = const [],
    this.replies = const [],
  });
  
  ChatMessage copyWith({
    String? id,
    int? userId,
    String? userName,
    String? message,
    DateTime? timestamp,
    List<String>? likes,
    List<ChatReply>? replies,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      replies: replies ?? this.replies,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'replies': replies.map((r) => r.toMap()).toList(),
    };
  }
  
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
      likes: List<String>.from(map['likes'] ?? []),
      replies: (map['replies'] as List<dynamic>?)
          ?.map((r) => ChatReply.fromMap(r))
          .toList() ?? [],
    );
  }
}

class ChatReply {
  final String id;
  final int userId;
  final String userName;
  final String message;
  final DateTime timestamp;
  final List<String> likes;
  
  ChatReply({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.timestamp,
    this.likes = const [],
  });
  
  ChatReply copyWith({
    String? id,
    int? userId,
    String? userName,
    String? message,
    DateTime? timestamp,
    List<String>? likes,
  }) {
    return ChatReply(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
    };
  }
  
  factory ChatReply.fromMap(Map<String, dynamic> map) {
    return ChatReply(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
      likes: List<String>.from(map['likes'] ?? []),
    );
  }
}

class ChatTopic {
  final String id;
  final String title;
  final String description;
  final int categoryId;
  final int creatorId;
  final String creatorName;
  final DateTime createdAt;
  final int messageCount;
  final DateTime lastActivityAt;
  
  ChatTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.creatorId,
    required this.creatorName,
    required this.createdAt,
    this.messageCount = 0,
    DateTime? lastActivityAt,
  }) : lastActivityAt = lastActivityAt ?? createdAt;
  
  ChatTopic copyWith({
    String? id,
    String? title,
    String? description,
    int? categoryId,
    int? creatorId,
    String? creatorName,
    DateTime? createdAt,
    int? messageCount,
    DateTime? lastActivityAt,
  }) {
    return ChatTopic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      messageCount: messageCount ?? this.messageCount,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'createdAt': createdAt.toIso8601String(),
      'messageCount': messageCount,
      'lastActivityAt': lastActivityAt.toIso8601String(),
    };
  }
  
  factory ChatTopic.fromMap(Map<String, dynamic> map) {
    return ChatTopic(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      categoryId: map['categoryId'],
      creatorId: map['creatorId'],
      creatorName: map['creatorName'],
      createdAt: DateTime.parse(map['createdAt']),
      messageCount: map['messageCount'] ?? 0,
      lastActivityAt: map['lastActivityAt'] != null
          ? DateTime.parse(map['lastActivityAt'])
          : null,
    );
  }
}

class ChatService {
  static final ChatService _instance = ChatService._internal();
  final AuthService _authService = AuthService();
  final Uuid _uuid = const Uuid();
  
  // In-memory storage for demo purposes
  final List<ChatTopic> _topics = [];
  final Map<String, List<ChatMessage>> _messages = {};
  
  factory ChatService() {
    return _instance;
  }
  
  ChatService._internal() {
    _initializeMockData();
  }
  
  void _initializeMockData() {
    if (_topics.isNotEmpty) return;
    
    // Create mock topics
    final topics = [
      ChatTopic(
        id: _uuid.v4(),
        title: 'Tips for 10th grade exams',
        description: 'Share your tips and strategies for 10th grade exams',
        categoryId: 1,
        creatorId: 101,
        creatorName: 'Study Expert',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        messageCount: 5,
      ),
      ChatTopic(
        id: _uuid.v4(),
        title: 'How to prepare for 12th board exams',
        description: 'Discuss preparation strategies for 12th board exams',
        categoryId: 3,
        creatorId: 102,
        creatorName: 'Board Topper',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        messageCount: 8,
      ),
      ChatTopic(
        id: _uuid.v4(),
        title: 'Career options after graduation',
        description: 'Explore various career paths after completing graduation',
        categoryId: 5,
        creatorId: 103,
        creatorName: 'Career Guide',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        messageCount: 12,
      ),
    ];
    
    for (final topic in topics) {
      _topics.add(topic);
      
      // Create mock messages for each topic
      final messages = <ChatMessage>[];
      
      for (int i = 0; i < topic.messageCount; i++) {
        final message = ChatMessage(
          id: _uuid.v4(),
          userId: 100 + i,
          userName: 'User ${100 + i}',
          message: 'This is message #${i + 1} in the topic "${topic.title}"',
          timestamp: topic.createdAt.add(Duration(hours: i * 2)),
          likes: i % 3 == 0 ? ['101', '102'] : [],
          replies: i % 2 == 0
              ? [
                  ChatReply(
                    id: _uuid.v4(),
                    userId: 200 + i,
                    userName: 'User ${200 + i}',
                    message: 'Reply to message #${i + 1}',
                    timestamp: topic.createdAt.add(Duration(hours: i * 2 + 1)),
                  ),
                ]
              : [],
        );
        
        messages.add(message);
      }
      
      _messages[topic.id] = messages;
    }
  }
  
  // Get all topics
  Future<List<ChatTopic>> getTopics() async {
    // In a real app, this would fetch from a database
    return _topics;
  }
  
  // Get topics by category
  Future<List<ChatTopic>> getTopicsByCategory(int categoryId) async {
    // In a real app, this would fetch from a database
    return _topics.where((t) => t.categoryId == categoryId).toList();
  }
  
  // Get a topic by ID
  Future<ChatTopic?> getTopicById(String topicId) async {
    // In a real app, this would fetch from a database
    return _topics.firstWhere((t) => t.id == topicId);
  }
  
  // Create a new topic
  Future<ChatTopic> createTopic({
    required String title,
    required String description,
    required int categoryId,
  }) async {
    if (!_authService.isLoggedIn) {
      throw Exception('User not logged in');
    }
    
    final userId = _authService.currentUserId!;
    final userName = _authService.currentUserName ?? 'Anonymous';
    
    final topic = ChatTopic(
      id: _uuid.v4(),
      title: title,
      description: description,
      categoryId: categoryId,
      creatorId: userId,
      creatorName: userName,
      createdAt: DateTime.now(),
    );
    
    // In a real app, this would save to a database
    _topics.add(topic);
    _messages[topic.id] = [];
    
    return topic;
  }
  
  // Get messages for a topic
  Future<List<ChatMessage>> getMessages(String topicId) async {
    // In a real app, this would fetch from a database
    return _messages[topicId] ?? [];
  }
  
  // Add a message to a topic
  Future<ChatMessage> addMessage({
    required String topicId,
    required String message,
  }) async {
    if (!_authService.isLoggedIn) {
      throw Exception('User not logged in');
    }
    
    final userId = _authService.currentUserId!;
    final userName = _authService.currentUserName ?? 'Anonymous';
    
    final chatMessage = ChatMessage(
      id: _uuid.v4(),
      userId: userId,
      userName: userName,
      message: message,
      timestamp: DateTime.now(),
    );
    
    // In a real app, this would save to a database
    _messages[topicId] ??= [];
    _messages[topicId]!.add(chatMessage);
    
    // Update topic message count and last activity
    final topicIndex = _topics.indexWhere((t) => t.id == topicId);
    if (topicIndex != -1) {
      _topics[topicIndex] = _topics[topicIndex].copyWith(
        messageCount: _topics[topicIndex].messageCount + 1,
        lastActivityAt: DateTime.now(),
      );
    }
    
    return chatMessage;
  }
  
  // Add a reply to a message
  Future<ChatReply> addReply({
    required String topicId,
    required String messageId,
    required String message,
  }) async {
    if (!_authService.isLoggedIn) {
      throw Exception('User not logged in');
    }
    
    final userId = _authService.currentUserId!;
    final userName = _authService.currentUserName ?? 'Anonymous';
    
    final reply = ChatReply(
      id: _uuid.v4(),
      userId: userId,
      userName: userName,
      message: message,
      timestamp: DateTime.now(),
    );
    
    // In a real app, this would save to a database
    final messages = _messages[topicId] ?? [];
    final messageIndex = messages.indexWhere((m) => m.id == messageId);
    
    if (messageIndex != -1) {
      final updatedReplies = [...messages[messageIndex].replies, reply];
      _messages[topicId]![messageIndex] = messages[messageIndex].copyWith(
        replies: updatedReplies,
      );
      
      // Update topic last activity
      final topicIndex = _topics.indexWhere((t) => t.id == topicId);
      if (topicIndex != -1) {
        _topics[topicIndex] = _topics[topicIndex].copyWith(
          lastActivityAt: DateTime.now(),
        );
      }
    }
    
    return reply;
  }
  
  // Like a message
  Future<void> likeMessage({
    required String topicId,
    required String messageId,
  }) async {
    if (!_authService.isLoggedIn) {
      throw Exception('User not logged in');
    }
    
    final userId = _authService.currentUserId!.toString();
    
    // In a real app, this would save to a database
    final messages = _messages[topicId] ?? [];
    final messageIndex = messages.indexWhere((m) => m.id == messageId);
    
    if (messageIndex != -1) {
      final currentLikes = [...messages[messageIndex].likes];
      
      if (currentLikes.contains(userId)) {
        currentLikes.remove(userId);
      } else {
        currentLikes.add(userId);
      }
      
      _messages[topicId]![messageIndex] = messages[messageIndex].copyWith(
        likes: currentLikes,
      );
    }
  }
  
  // Like a reply
  Future<void> likeReply({
    required String topicId,
    required String messageId,
    required String replyId,
  }) async {
    if (!_authService.isLoggedIn) {
      throw Exception('User not logged in');
    }
    
    final userId = _authService.currentUserId!.toString();
    
    // In a real app, this would save to a database
    final messages = _messages[topicId] ?? [];
    final messageIndex = messages.indexWhere((m) => m.id == messageId);
    
    if (messageIndex != -1) {
      final replies = [...messages[messageIndex].replies];
      final replyIndex = replies.indexWhere((r) => r.id == replyId);
      
      if (replyIndex != -1) {
        final currentLikes = [...replies[replyIndex].likes];
        
        if (currentLikes.contains(userId)) {
          currentLikes.remove(userId);
        } else {
          currentLikes.add(userId);
        }
        
        replies[replyIndex] = replies[replyIndex].copyWith(
          likes: currentLikes,
        );
        
        _messages[topicId]![messageIndex] = messages[messageIndex].copyWith(
          replies: replies,
        );
      }
    }
  }
}
