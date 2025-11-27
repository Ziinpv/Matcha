import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String text;
  final DateTime createdAt;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "message_id": messageId,
      "sender_id": senderId,
      "text": text,
      "created_at": Timestamp.fromDate(createdAt),
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map["message_id"],
      senderId: map["sender_id"],
      text: map["text"],
      createdAt: (map["created_at"] as Timestamp).toDate(),
    );
  }
}
