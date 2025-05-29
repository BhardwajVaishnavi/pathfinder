import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show TimeOfDay;
// import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Removed for build
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timezone/timezone.dart' as tz; // Removed for build
// import 'package:timezone/data/latest.dart' as tz_data; // Removed for build
import 'auth_service.dart';

class AppNotification {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    this.isRead = false,
  });

  AppNotification copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? scheduledDate,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      scheduledDate: DateTime.parse(map['scheduledDate']),
      isRead: map['isRead'] ?? false,
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  // final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(); // Removed for build
  final AuthService _authService = AuthService();

  // Shared preferences keys
  static const String _notificationsKey = 'notifications';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _reminderTimeKey = 'reminder_time';

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    if (kIsWeb) return; // Skip initialization on web
    // Simplified for build - notifications disabled
    print('Notifications temporarily disabled for build');
  }

  // Get all notifications for the current user
  Future<List<AppNotification>> getNotifications() async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      if (kIsWeb) {
        // Return mock data for web
        return [
          AppNotification(
            id: 1,
            title: 'Daily Reminder',
            body: 'Don\'t forget to take your daily test!',
            scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
            isRead: true,
          ),
          AppNotification(
            id: 2,
            title: 'New Achievement Unlocked',
            body: 'Congratulations! You\'ve unlocked the "First Steps" achievement.',
            scheduledDate: DateTime.now().subtract(const Duration(hours: 5)),
            isRead: false,
          ),
          AppNotification(
            id: 3,
            title: 'Weekly Summary',
            body: 'You\'ve completed 3 tests this week. Keep up the good work!',
            scheduledDate: DateTime.now().subtract(const Duration(hours: 2)),
            isRead: false,
          ),
        ];
      }

      // Get notifications from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = _authService.currentUserId!;
      final notificationsJson = prefs.getStringList('${_notificationsKey}_$userId') ?? [];

      if (notificationsJson.isEmpty) {
        return [];
      }

      // Parse notifications from JSON
      final notifications = notificationsJson.map((json) =>
        AppNotification.fromMap(Map<String, dynamic>.from(
          Map<String, dynamic>.from(json as Map)
        ))
      ).toList();

      // Sort notifications by date (newest first)
      notifications.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

      return notifications;
    } catch (e) {
      print('Error getting notifications: $e');
      rethrow;
    }
  }

  // Schedule a notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      if (kIsWeb) return; // Skip scheduling on web

      // Check if notifications are enabled
      final isEnabled = await areNotificationsEnabled();
      if (!isEnabled) return;

      final userId = _authService.currentUserId!;

      // Generate notification ID
      final notifications = await getNotifications();
      final id = notifications.isEmpty ? 1 : notifications.map((n) => n.id).reduce((a, b) => a > b ? a : b) + 1;

      // Schedule notification - simplified for build
      print('Notification scheduled: $title - $body');

      // Save notification to shared preferences
      final notification = AppNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      );

      await _saveNotification(notification);
    } catch (e) {
      print('Error scheduling notification: $e');
      rethrow;
    }
  }

  // Mark a notification as read
  Future<void> markNotificationAsRead(int id) async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      if (kIsWeb) return; // Skip on web

      final userId = _authService.currentUserId!;

      // Get notifications
      final notifications = await getNotifications();

      // Find and update the notification
      final index = notifications.indexWhere((n) => n.id == id);
      if (index == -1) return;

      notifications[index] = notifications[index].copyWith(isRead: true);

      // Save updated notifications
      await _saveNotifications(notifications);
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      if (kIsWeb) return; // Skip on web

      final userId = _authService.currentUserId!;

      // Get notifications
      final notifications = await getNotifications();

      // Mark all as read
      final updatedNotifications = notifications.map((n) => n.copyWith(isRead: true)).toList();

      // Save updated notifications
      await _saveNotifications(updatedNotifications);
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Schedule daily reminder
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      if (kIsWeb) return; // Skip on web

      // Save reminder time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_reminderTimeKey, '${time.hour}:${time.minute}');

      // Cancel existing reminders - simplified for build
      print('Cancelling existing reminders');

      // Schedule new reminder
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If the scheduled time is in the past, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Schedule notification
      await scheduleNotification(
        title: 'Daily Reminder',
        body: 'Don\'t forget to take your daily test!',
        scheduledDate: scheduledDate,
      );
    } catch (e) {
      print('Error scheduling daily reminder: $e');
      rethrow;
    }
  }

  // Enable or disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      if (kIsWeb) return; // Skip on web

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, enabled);

      if (!enabled) {
        // Cancel all scheduled notifications - simplified for build
        print('Cancelling all notifications');
      } else {
        // Re-schedule daily reminder if it was set
        final reminderTimeString = prefs.getString(_reminderTimeKey);
        if (reminderTimeString != null) {
          final parts = reminderTimeString.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          await scheduleDailyReminder(TimeOfDay(hour: hour, minute: minute));
        }
      }
    } catch (e) {
      print('Error setting notifications enabled: $e');
      rethrow;
    }
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      if (kIsWeb) return false; // Skip on web

      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationsEnabledKey) ?? false;
    } catch (e) {
      print('Error checking if notifications are enabled: $e');
      return false;
    }
  }

  // Get the daily reminder time
  Future<TimeOfDay?> getDailyReminderTime() async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      if (kIsWeb) return const TimeOfDay(hour: 9, minute: 0); // Default for web

      final prefs = await SharedPreferences.getInstance();
      final reminderTimeString = prefs.getString(_reminderTimeKey);

      if (reminderTimeString == null) return null;

      final parts = reminderTimeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print('Error getting daily reminder time: $e');
      return null;
    }
  }

  // Save a notification to shared preferences
  Future<void> _saveNotification(AppNotification notification) async {
    final notifications = await getNotifications();
    notifications.add(notification);
    await _saveNotifications(notifications);
  }

  // Save notifications to shared preferences
  Future<void> _saveNotifications(List<AppNotification> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _authService.currentUserId!;
    final notificationsJson = notifications.map((n) => n.toMap()).toList();
    await prefs.setStringList('${_notificationsKey}_$userId',
      notificationsJson.map((n) => n.toString()).toList()
    );
  }
}
