import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String roomId;
  final String user1Id;
  final String user2Id;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final DateTime createdAt;

  ChatRoomModel({
    required this.roomId,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
  });

  Map<String, dynamic> toMap() {
    return {
      "room_id": roomId,
      "user1_id": user1Id,
      "user2_id": user2Id,
      "created_at": Timestamp.fromDate(createdAt),
      "last_message": lastMessage,
      "last_message_time": lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
    };
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      roomId: map["room_id"],
      user1Id: map["user1_id"],
      user2Id: map["user2_id"],
      createdAt: (map["created_at"] as Timestamp).toDate(),
      lastMessage: map["last_message"],
      lastMessageTime: map["last_message_time"] != null
          ? (map["last_message_time"] as Timestamp).toDate()
          : null,
    );
  }
}
