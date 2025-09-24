import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String matchId;
  final String senderId;
  final String content;
  final String type;
  final DateTime createdAt;

  Message({
    required this.messageId,
    required this.matchId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['message_id'],
      matchId: map['match_id'],
      senderId: map['sender_id'],
      content: map['content'],
      type: map['type'],
      createdAt: (map['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message_id': messageId,
      'match_id': matchId,
      'sender_id': senderId,
      'content': content,
      'type': type,
      'created_at': createdAt,
    };
  }
}
