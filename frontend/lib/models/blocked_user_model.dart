// lib/models/blocked_user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BlockedUserModel {
  final String blockId;
  final String blockerId;
  final String blockedId;
  final String? reason;
  final DateTime? createdAt;

  BlockedUserModel({
    required this.blockId,
    required this.blockerId,
    required this.blockedId,
    this.reason,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'block_id': blockId,
      'blocker_id': blockerId,
      'blocked_id': blockedId,
      'reason': reason ?? '',
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory BlockedUserModel.fromMap(Map<String, dynamic> map) {
    return BlockedUserModel(
      blockId: map['block_id'] ?? '',
      blockerId: map['blocker_id'] ?? '',
      blockedId: map['blocked_id'] ?? '',
      reason: (map['reason'] as String?)?.isNotEmpty == true ? map['reason'] : null,
      createdAt: map['created_at'] != null ? (map['created_at'] as Timestamp).toDate() : null,
    );
  }

  factory BlockedUserModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return BlockedUserModel.fromMap(data);
  }
}
