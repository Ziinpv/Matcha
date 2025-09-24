import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String matchId;
  final String user1Id;
  final String user2Id;
  final String status;
  final DateTime createdAt;

  MatchModel({
    required this.matchId,
    required this.user1Id,
    required this.user2Id,
    required this.status,
    required this.createdAt,
  });

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      matchId: map['match_id'],
      user1Id: map['user1_id'],
      user2Id: map['user2_id'],
      status: map['status'],
      createdAt: (map['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'match_id': matchId,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'status': status,
      'created_at': createdAt,
    };
  }
}
