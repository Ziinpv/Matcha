// lib/models/like_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class LikeModel {
  final String likeId;
  final String fromUserId; // user thực hiện hành động
  final String toUserId;   // user bị like/dislike
  final String action;     // like, dislike, superlike
  final DateTime? createdAt;

  LikeModel({
    required this.likeId,
    required this.fromUserId,
    required this.toUserId,
    required this.action,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'like_id': likeId,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'action': action,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory LikeModel.fromMap(Map<String, dynamic> map) {
    return LikeModel(
      likeId: map['like_id'] ?? '',
      fromUserId: map['from_user_id'] ?? '',
      toUserId: map['to_user_id'] ?? '',
      action: map['action'] ?? 'like',
      createdAt: map['created_at'] != null
          ? (map['created_at'] as Timestamp).toDate()
          : null,
    );
  }

  factory LikeModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return LikeModel.fromMap(data);
  }
}
