// lib/models/message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String matchId;
  final String senderId;
  final String? content;
  final String? type; // text/image/other
  final DateTime? createdAt;
  final bool? isRead;

  MessageModel({
    required this.messageId,
    required this.matchId,
    required this.senderId,
    this.content,
    this.type,
    this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'message_id': messageId,
      'match_id': matchId,
      'sender_id': senderId,
      'content': content ?? '',
      'type': type ?? 'text',
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'is_read': isRead ?? false,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['message_id'] ?? '',
      matchId: map['match_id'] ?? '',
      senderId: map['sender_id'] ?? '',
      content: (map['content'] as String?)?.isNotEmpty == true ? map['content'] : null,
      type: (map['type'] as String?)?.isNotEmpty == true ? map['type'] : null,
      createdAt: map['created_at'] != null ? (map['created_at'] as Timestamp).toDate() : null,
      isRead: map['is_read'] ?? false,
    );
  }

  factory MessageModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return MessageModel.fromMap(data);
  }
}
