import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _chatRoomCollection = "chat_rooms";

  // ---------------------------------------------------------
  // 1) Tạo chat room khi 2 người match
  // ---------------------------------------------------------
  Future<String> createChatRoom(String userA, String userB) async {
    // Kiểm tra đã có room chưa
    final exist = await _firestore
        .collection(_chatRoomCollection)
        .where("user1_id", isEqualTo: userA)
        .where("user2_id", isEqualTo: userB)
        .limit(1)
        .get();

    if (exist.docs.isNotEmpty) {
      return exist.docs.first.id;
    }

    final exist2 = await _firestore
        .collection(_chatRoomCollection)
        .where("user1_id", isEqualTo: userB)
        .where("user2_id", isEqualTo: userA)
        .limit(1)
        .get();

    if (exist2.docs.isNotEmpty) {
      return exist2.docs.first.id;
    }

    // Tạo room mới
    final roomId = _firestore.collection(_chatRoomCollection).doc().id;

    final room = ChatRoomModel(
      roomId: roomId,
      user1Id: userA,
      user2Id: userB,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(_chatRoomCollection)
        .doc(roomId)
        .set(room.toMap());

    return roomId;
  }

  // ---------------------------------------------------------
  // 2) Lấy danh sách chatroom của 1 user (để hiển thị trong ChatScreen)
  // ---------------------------------------------------------
  Stream<List<ChatRoomModel>> getUserChatRooms(String userId) {
    return _firestore
        .collection(_chatRoomCollection)
        .where("user1_id", isEqualTo: userId)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => ChatRoomModel.fromMap(d.data())).toList());
  }

  // ---------------------------------------------------------
  // 3) Lấy tin nhắn realtime
  // ---------------------------------------------------------
  Stream<List<MessageModel>> getMessages(String roomId) {
    return _firestore
        .collection("chat_rooms/$roomId/messages")
        .orderBy("created_at", descending: false)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => MessageModel.fromMap(d.data())).toList());
  }

  // ---------------------------------------------------------
  // 4) Gửi tin nhắn
  // ---------------------------------------------------------
  Future<void> sendMessage(
      String roomId,
      String senderId,
      String text,
      ) async {
    final msgId = _firestore
        .collection("chat_rooms/$roomId/messages")
        .doc()
        .id;

    final msg = MessageModel(
      messageId: msgId,
      senderId: senderId,
      text: text,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection("chat_rooms/$roomId/messages")
        .doc(msgId)
        .set(msg.toMap());

    // Update last message
    await _firestore.collection(_chatRoomCollection).doc(roomId).update({
      "last_message": text,
      "last_message_time": Timestamp.fromDate(DateTime.now()),
    });
  }
}
