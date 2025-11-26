// lib/models/match_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String matchId;
  final String user1Id;
  final String user2Id;
  final String? status; // active, ended, blocked
  final DateTime? createdAt;

  MatchModel({
    required this.matchId,
    required this.user1Id,
    required this.user2Id,
    this.status,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'match_id': matchId,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'status': status ?? 'active',
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      matchId: map['match_id'] ?? '',
      user1Id: map['user1_id'] ?? '',
      user2Id: map['user2_id'] ?? '',
      status: map['status'] ?? 'active',
      createdAt: map['created_at'] != null
          ? (map['created_at'] as Timestamp).toDate()
          : null,
    );
  }

  factory MatchModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return MatchModel.fromMap(data);
  }
}
