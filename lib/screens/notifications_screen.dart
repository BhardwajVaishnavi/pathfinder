import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = true;
  String _errorMessage = '';

  // Notification data
  List<AppNotification> _notifications = [];
  bool _notificationsEnabled = false;
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    _loadNotificationData();
  }

  Future<void> _loadNotificationData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load notifications, settings
      _notifications = await _notificationService.getNotifications();
      _notificationsEnabled = await _notificationService.areNotificationsEnabled();
      _reminderTime = await _notificationService.getDailyReminderTime();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load notification data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _notificationService.markAllNotificationsAsRead();
      await _loadNotificationData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to mark notifications as read: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _notificationService.setNotificationsEnabled(value);

      if (value && _reminderTime == null) {
        // Set default reminder time to 9:00 AM
        await _setReminderTime(const TimeOfDay(hour: 9, minute: 0));
      }

      await _loadNotificationData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update notification settings: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _setReminderTime(TimeOfDay? time) async {
    if (time == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _notificationService.scheduleDailyReminder(time);
      await _loadNotificationData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to set reminder time: ${e.toString()}';
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
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading notifications...')
          : _errorMessage.isNotEmpty
              ? ErrorMessage(
                  message: _errorMessage,
                  onRetry: _loadNotificationData,
                )
              : Column(
                  children: [
                    _buildNotificationSettings(),
                    Expanded(
                      child: _buildNotificationsList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Enable Notifications',
                style: AppTextStyles.subtitle1,
              ),
              Switch(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                activeColor: AppColors.primary,
              ),
            ],
          ),
          if (_notificationsEnabled) ...[
            const SizedBox(height: AppDimensions.paddingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily Reminder',
                  style: AppTextStyles.subtitle1,
                ),
                TextButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (time != null) {
                      _setReminderTime(time);
                    }
                  },
                  child: Text(
                    _reminderTime != null
                        ? _reminderTime!.format(context)
                        : 'Set Time',
                    style: AppTextStyles.bodyText1.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return RefreshIndicator(
      onRefresh: _loadNotificationData,
      child: _notifications.isEmpty
          ? const Center(
              child: Text(
                'No notifications',
                style: AppTextStyles.subtitle1,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: InkWell(
        onTap: () async {
          if (!notification.isRead) {
            await _notificationService.markNotificationAsRead(notification.id);
            await _loadNotificationData();
          }
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: notification.isRead ? Colors.transparent : AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTextStyles.subtitle1.copyWith(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(
                      notification.body,
                      style: AppTextStyles.bodyText2,
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Text(
                      _formatNotificationDate(notification.scheduledDate),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNotificationDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return DateFormatter.formatDate(date);
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
