// lib/services/like_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/like_model.dart';
import '../models/match_model.dart';

class LikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _likesCollection = "likes";
  final String _matchesCollection = "matches";

  /// LIKE USER (A → B)
  Future<void> likeUser(String fromUserId, String toUserId) async {
    if (fromUserId == toUserId) return;

    // Check trùng like
    final existed = await _firestore
        .collection(_likesCollection)
        .where('from_user_id', isEqualTo: fromUserId)
        .where('to_user_id', isEqualTo: toUserId)
        .where('action', isEqualTo: 'like')
        .limit(1)
        .get();

    if (existed.docs.isNotEmpty) {
      print("⚠️ User đã like trước đó → bỏ qua");
      return;
    }

    // Tạo like
    final likeId = _firestore.collection(_likesCollection).doc().id;
    final newLike = LikeModel(
      likeId: likeId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      action: "like",
      createdAt: DateTime.now(),
    );

    await _firestore.collection(_likesCollection).doc(likeId).set(newLike.toMap());

    // Kiểm tra mutual
    await _checkMutualLike(fromUserId, toUserId);
  }

  /// DISLIKE USER
  Future<void> dislikeUser(String fromUserId, String toUserId) async {
    final dislikeId = _firestore.collection(_likesCollection).doc().id;

    final dislike = LikeModel(
      likeId: dislikeId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      action: "dislike",
      createdAt: DateTime.now(),
    );

    await _firestore.collection(_likesCollection).doc(dislikeId).set(dislike.toMap());
  }

  /// CHECK MUTUAL
  Future<void> _checkMutualLike(String userA, String userB) async {
    final reverse = await _firestore
        .collection(_likesCollection)
        .where('from_user_id', isEqualTo: userB)
        .where('to_user_id', isEqualTo: userA)
        .where('action', isEqualTo: 'like')
        .limit(1)
        .get();

    if (reverse.docs.isNotEmpty) {
      print("🎉 MATCH FOUND!");
      await _createMatch(userA, userB);
    }
  }

  /// CREATE MATCH (user1_id – user2_id)
  Future<void> _createMatch(String userA, String userB) async {
    final exist1 = await _firestore
        .collection(_matchesCollection)
        .where('user1_id', isEqualTo: userA)
        .where('user2_id', isEqualTo: userB)
        .limit(1)
        .get();

    final exist2 = await _firestore
        .collection(_matchesCollection)
        .where('user1_id', isEqualTo: userB)
        .where('user2_id', isEqualTo: userA)
        .limit(1)
        .get();

    if (exist1.docs.isNotEmpty || exist2.docs.isNotEmpty) {
      print("⚠️ Match đã tồn tại → bỏ qua");
      return;
    }

    final matchId = _firestore.collection(_matchesCollection).doc().id;
    final match = MatchModel(
      matchId: matchId,
      user1Id: userA,
      user2Id: userB,
      status: "active",
      createdAt: DateTime.now(),
    );

    await _firestore.collection(_matchesCollection).doc(matchId).set(match.toMap());
    print("🔥 MATCH CREATED: $matchId");
  }

  /// danh sách user mình đã quẹt
  Future<List<String>> getAllSwipedUsers(String userId) async {
    final snapshot = await _firestore
        .collection(_likesCollection)
        .where('from_user_id', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => doc['to_user_id'] as String).toList();
  }

  /// RESET DỮ LIỆU TEST CHO USER HIỆN TẠI
  Future<void> resetUserData(String userId) async {
    WriteBatch batch = _firestore.batch();

    // Xoá toàn bộ likes do user tạo
    final likes = await _firestore
        .collection(_likesCollection)
        .where('from_user_id', isEqualTo: userId)
        .get();

    for (var doc in likes.docs) {
      batch.delete(doc.reference);
    }

    // Xoá match liên quan user
    final match1 = await _firestore
        .collection(_matchesCollection)
        .where('user1_id', isEqualTo: userId)
        .get();

    for (var doc in match1.docs) {
      batch.delete(doc.reference);
    }

    final match2 = await _firestore
        .collection(_matchesCollection)
        .where('user2_id', isEqualTo: userId)
        .get();

    for (var doc in match2.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    print("🧹 Reset dữ liệu test cho user $userId xong.");
  }
}
