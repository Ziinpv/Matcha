// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  /// Lấy user theo UID
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore.collection(_collection).doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'],
      gender: data['gender'],
      bio: data['bio'],
      avatarUrl: data['avatar_url'],
      birthdate: data['birthdate'] != null ? (data['birthdate'] as Timestamp).toDate() : null,
      location: data['location'],
      interests: data['interests'] != null ? List<String>.from(data['interests']) : [],
      profileCompleted: data['profile_completed'] ?? false,
      createdAt: data['created_at'] != null ? (data['created_at'] as Timestamp).toDate() : null,
    );
  }

  /// Tạo user mới nếu chưa có
  Future<void> createUser(UserModel user) async {
    final docRef = _firestore.collection(_collection).doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set(user.toMap());
    }
  }

  /// Cập nhật user bất kỳ trường nào
  Future<void> updateUser(String uid, Map<String, dynamic> update) async {
    await _firestore.collection(_collection).doc(uid).update(update);
  }

  /// Kiểm tra profile đã hoàn thiện
  Future<bool> userHasCompleteProfile(String uid) async {
    final user = await getUserById(uid);
    return user?.profileCompleted ?? false;
  }

  /// Hoàn thiện profile và cập nhật dữ liệu
  Future<void> completeProfile(String uid, Map<String, dynamic> payload) async {
    // Validate các trường bắt buộc
    final hasRequiredFields =
        (payload['name'] != null && payload['name'].toString().trim().isNotEmpty) &&
            (payload['gender'] != null && payload['gender'].toString().trim().isNotEmpty) &&
            (payload['birthdate'] != null) &&
            (payload['interests'] != null && payload['interests'] is List && (payload['interests'] as List).isNotEmpty) &&
            (payload['location'] != null && payload['location'].toString().trim().isNotEmpty);

    final update = {
      'name': payload['name'] ?? payload['displayName'],
      'avatar_url': payload['avatarUrl'] ?? payload['avatar_url'],
      'bio': payload['bio'],
      'gender': payload['gender'],
      'birthdate': payload['birthdate'],
      'location': payload['location'],
      'interests': payload['interests'],
      'preferences': payload['preferences'],
      'profile_completed': hasRequiredFields, // ← CHỈ TRUE KHI ĐỦ TẤT CẢ TRƯỜNG BẮT BUỘC
    };

    // Loại bỏ các trường null
    update.removeWhere((key, value) => value == null);

    await updateUser(uid, update);
  }

  /// Lấy danh sách tất cả user đã hoàn thiện profile
  Future<List<UserModel>> getAllCompletedUsers() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('profile_completed', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return UserModel(
        uid: doc.id,
        email: data['email'] ?? '',
        name: data['name'],
        gender: data['gender'],
        bio: data['bio'],
        avatarUrl: data['avatar_url'],
        birthdate: data['birthdate'] != null ? (data['birthdate'] as Timestamp).toDate() : null,
        location: data['location'],
        interests: data['interests'] != null ? List<String>.from(data['interests']) : [],
        profileCompleted: data['profile_completed'] ?? false,
        createdAt: data['created_at'] != null ? (data['created_at'] as Timestamp).toDate() : null,
      );
    }).toList();
  }
}
