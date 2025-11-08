import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 Lấy UID người dùng hiện tại (nếu đã đăng nhập)
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// 🔹 Lấy danh sách người dùng khác (trừ bản thân)
  /// Có thể thêm filter `profileComplete = true` nếu bạn chỉ muốn hiển thị người dùng có hồ sơ hoàn chỉnh.
  // Future<List<UserModel>> fetchAllUsers({String? currentUserId}) async {
  //   Query query = _firestore.collection('users');
  //
  //   // Lọc bỏ bản thân
  //   if (currentUserId != null) {
  //     query = query.where('user_id', isNotEqualTo: currentUserId);
  //   }
  //
  //   // Chỉ lấy người đã hoàn thiện hồ sơ (nếu có trường này)
  //   query = query.where('profileComplete', isEqualTo: true);
  //
  //   final snapshot = await query.get();
  //
  //   return snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
  // }

  Future<List<UserModel>> fetchAllUsers({required String currentUserId}) async {
    try {
      final snapshot = await _firestore.collection('users').get();

      print('🔥 Tổng số user trong Firestore: ${snapshot.docs.length}');
      for (var doc in snapshot.docs) {
        print('👤 ${doc.data()}');
      }

      final users = snapshot.docs
          .map((doc) => UserModel.fromSnapshot(doc))
          .where((user) => user.uid != currentUserId)
          .toList();

      print('✅ Sau khi loại bỏ chính mình: ${users.length} user khả dụng');
      return users;
    } catch (e) {
      print('❌ Lỗi khi fetch user: $e');
      return [];
    }
  }

  /// 🔹 Lấy thông tin 1 người dùng cụ thể
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromSnapshot(doc);
  }

  /// 🔹 Cập nhật hồ sơ người dùng
  Future<void> updateUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  /// 🔹 Lấy danh sách người dùng theo giới tính (ví dụ lọc match)
  Future<List<UserModel>> fetchUsersByGender(String gender, {String? currentUserId}) async {
    Query query = _firestore.collection('users').where('gender', isEqualTo: gender);
    if (currentUserId != null) {
      query = query.where('user_id', isNotEqualTo: currentUserId);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
  }

  /// 🔹 Tạo hoặc cập nhật người dùng mới (sử dụng trong Google Login / Register)
  Future<void> createOrUpdateUser(UserModel user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.update(user.toMap());
    } else {
      await docRef.set(user.toMap());
    }
  }
}
