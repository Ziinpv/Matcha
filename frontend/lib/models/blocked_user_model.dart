import 'package:cloud_firestore/cloud_firestore.dart';

class BlockedUser {
  final String blockId;
  final String blockerId;
  final String blockedId;
  final String? reason;
  final DateTime createdAt;

  BlockedUser({
    required this.blockId,
    required this.blockerId,
    required this.blockedId,
    this.reason,
    required this.createdAt,
  });

  factory BlockedUser.fromMap(Map<String, dynamic> map) {
    return BlockedUser(
      blockId: map['block_id'],
      blockerId: map['blocker_id'],
      blockedId: map['blocked_id'],
      reason: map['reason'],
      createdAt: (map['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'block_id': blockId,
      'blocker_id': blockerId,
      'blocked_id': blockedId,
      'reason': reason,
      'created_at': createdAt,
    };
  }
}
