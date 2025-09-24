import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notifId;
  final String userId;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool read;

  NotificationModel({
    required this.notifId,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.read = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notifId: map['notif_id'],
      userId: map['user_id'],
      title: map['title'],
      message: map['message'],
      type: map['type'],
      createdAt: (map['created_at'] as Timestamp).toDate(),
      read: map['read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notif_id': notifId,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'created_at': createdAt,
      'read': read,
    };
  }
}
