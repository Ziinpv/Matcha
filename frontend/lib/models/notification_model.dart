// lib/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notifId;
  final String userId;
  final String? title;
  final String? message;
  final String? type;
  final DateTime? createdAt;
  final bool? read;

  NotificationModel({
    required this.notifId,
    required this.userId,
    this.title,
    this.message,
    this.type,
    this.createdAt,
    this.read = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'notif_id': notifId,
      'user_id': userId,
      'title': title ?? '',
      'message': message ?? '',
      'type': type ?? '',
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'read': read ?? false,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notifId: map['notif_id'] ?? '',
      userId: map['user_id'] ?? '',
      title: (map['title'] as String?)?.isNotEmpty == true ? map['title'] : null,
      message: (map['message'] as String?)?.isNotEmpty == true ? map['message'] : null,
      type: (map['type'] as String?)?.isNotEmpty == true ? map['type'] : null,
      createdAt: map['created_at'] != null ? (map['created_at'] as Timestamp).toDate() : null,
      read: map['read'] ?? false,
    );
  }

  factory NotificationModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return NotificationModel.fromMap(data);
  }
}
