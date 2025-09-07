import 'package:flutter/material.dart';

enum NotificationType {
  like,
  superlike,
  match,
  message,
  view,
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? userName;
  final String? userAvatar;

  AppNotification({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.userName,
    this.userAvatar,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      type: NotificationType.match,
      message: 'Bạn và Linh đã kết đôi! 🎉',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
      userName: 'Linh',
      userAvatar: 'assets/profilepic.jpg',
    ),
    AppNotification(
      id: '2',
      type: NotificationType.like,
      message: 'Có người mới thích bạn!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    AppNotification(
      id: '3',
      type: NotificationType.message,
      message: 'Bạn có tin nhắn mới từ Minh',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: true,
      userName: 'Minh',
      userAvatar: 'assets/profilepic.jpg',
    ),
    AppNotification(
      id: '4',
      type: NotificationType.superlike,
      message: 'Ai đó đã super like bạn! ⭐',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
    ),
    AppNotification(
      id: '5',
      type: NotificationType.view,
      message: 'Hương đã xem hồ sơ của bạn',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      userName: 'Hương',
      userAvatar: 'assets/profilepic.jpg',
    ),
  ];

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = AppNotification(
          id: _notifications[index].id,
          type: _notifications[index].type,
          message: _notifications[index].message,
          timestamp: _notifications[index].timestamp,
          isRead: true,
          userName: _notifications[index].userName,
          userAvatar: _notifications[index].userAvatar,
        );
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => AppNotification(
        id: n.id,
        type: n.type,
        message: n.message,
        timestamp: n.timestamp,
        isRead: true,
        userName: n.userName,
        userAvatar: n.userAvatar,
      )).toList();
    });
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.superlike:
        return Icons.star;
      case NotificationType.match:
        return Icons.flash_on;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.view:
        return Icons.visibility;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return const Color(0xFFFF4B91);
      case NotificationType.superlike:
        return Colors.blue;
      case NotificationType.match:
        return Colors.green;
      case NotificationType.message:
        return Colors.blue;
      case NotificationType.view:
        return Colors.purple;
    }
  }

  Color _getNotificationBackgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return const Color(0xFFFF4B91).withOpacity(0.1);
      case NotificationType.superlike:
        return Colors.blue.withOpacity(0.1);
      case NotificationType.match:
        return Colors.green.withOpacity(0.1);
      case NotificationType.message:
        return Colors.blue.withOpacity(0.1);
      case NotificationType.view:
        return Colors.purple.withOpacity(0.1);
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa mới';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.message:
        // Navigate to chat
        break;
      case NotificationType.match:
      case NotificationType.like:
      case NotificationType.superlike:
        // Navigate to matches
        break;
      case NotificationType.view:
        // Navigate to profile or matches
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông báo', style: TextStyle(color: Colors.black)),
            if (unreadCount > 0)
              Text(
                '$unreadCount thông báo chưa đọc',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        centerTitle: false,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Đọc tất cả',
                style: TextStyle(
                  color: Color(0xFFFF4B91),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _notifications.isEmpty ? _buildEmptyState() : _buildNotificationsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 40,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có thông báo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Các thông báo về lượt thích, kết đôi và tin nhắn\nsẽ xuất hiện ở đây',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4B91),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Bắt đầu khám phá',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : _getNotificationBackgroundColor(notification.type),
        borderRadius: BorderRadius.circular(12),
        border: notification.isRead 
            ? Border.all(color: Colors.grey[200]!)
            : Border.all(color: _getNotificationColor(notification.type), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: Colors.white,
                size: 20,
              ),
            ),
            if (notification.userAvatar != null) ...[
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(notification.userAvatar!),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  ),
                  color: Colors.grey[300],
                ),
              ),
            ],
          ],
        ),
        title: Text(
          notification.message,
          style: TextStyle(
            fontSize: 16,
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _formatTime(notification.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type),
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }
}
