// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ===== Đăng nhập bằng email/password =====
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred.user;
    } on FirebaseAuthException catch (e) {
      print("Error login: $e");
      throw e;
    }
  }

  // ===== Đăng ký bằng email/password =====
  Future<User?> registerWithEmail(String email, String password, String name) async {
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCred.user;

      if (user != null) {
        final hash = sha256.convert(utf8.encode(password)).toString();

        await _db.collection('users').doc(user.uid).set({
          'user_id': user.uid,
          'name': name,
          'email': email,
          'password_hash': hash,
          'location': null, // user sẽ update trong profile
          'birthdate': null,
          'gender': null,
          'interests': [],
          'bio': '',
          'avatar_url': '',
          'created_at': FieldValue.serverTimestamp(),
          'role': 'user',
          'profile_completed': false, // mặc định chưa hoàn thiện
        }, SetOptions(merge: true));
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print("Error register: $e");
      throw e;
    }
  }

  // ===== Đăng nhập bằng Google =====
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        final doc = _db.collection('users').doc(user.uid);
        final snapshot = await doc.get();
        if (!snapshot.exists) {
          await doc.set({
            'user_id': user.uid,
            'name': user.displayName ?? "",
            'email': user.email,
            'location': null,
            'birthdate': null,
            'gender': null,
            'interests': [],
            'bio': '',
            'avatar_url': user.photoURL ?? '',
            'created_at': FieldValue.serverTimestamp(),
            'role': 'user',
            'profile_completed': false,
          }, SetOptions(merge: true));
        }
      }

      return user;
    } catch (e) {
      print("Error google login: $e");
      return null;
    }
  }

  // Alias
  Future<User?> loginWithGoogle() async => await signInWithGoogle();

  // ===== Cập nhật thông tin profile (và cập nhật profile_completed) =====
  /// `data` là map chứa các field user cập nhật (name, gender, birthdate, location, interests, ...)
  /// Hàm sẽ merge update vào doc user và tự set profile_completed nếu đạt điều kiện.
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    final docRef = _db.collection("users").doc(user.uid);

    // Merge update
    await docRef.set(data, SetOptions(merge: true));

    // Sau khi update, kiểm tra profile hoàn chỉnh hay chưa và set flag profile_completed
    final complete = await userHasCompleteProfile(user.uid);
    await docRef.set({'profile_completed': complete}, SetOptions(merge: true));
  }

  // ===== Quên mật khẩu =====
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ===== Xóa user cả Firestore + FirebaseAuth =====
  Future<void> deleteUserCompletely() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    await _db.collection('users').doc(user.uid).delete();
    await user.delete();
  }

  // ===== Kiểm tra hồ sơ =====

  /// Kiểm tra nhanh thông qua flag `profile_completed` nếu có.
  /// Nếu không có flag, sẽ load document và kiểm tra các trường bắt buộc.
  Future<bool> userHasCompleteProfile(String uid) async {
    final docRef = _db.collection('users').doc(uid);
    final snap = await docRef.get();

    if (!snap.exists) return false;

    final data = snap.data()!;

    // 1) Nếu đã có flag thì dùng luôn
    if (data.containsKey('profile_completed')) {
      final flag = data['profile_completed'];
      if (flag is bool) return flag;
    }

    // 2) Nếu không có flag, kiểm tra các field bắt buộc
    // Các field bắt buộc bạn yêu cầu: name, gender, birthdate, location, interests (>=1)
    final name = (data['name'] as String?) ?? '';
    final gender = (data['gender'] as String?) ?? '';
    final birthdate = data['birthdate']; // Timestamp hoặc String or null
    final location = (data['location'] as String?) ?? '';
    final interests = data['interests'];

    bool hasName = name.trim().isNotEmpty;
    bool hasGender = gender.trim().isNotEmpty;
    bool hasLocation = location.trim().isNotEmpty;
    bool hasBirthdate = birthdate != null; // birthdate stored as Timestamp
    bool hasInterests = false;
    if (interests is List) {
      hasInterests = interests.where((e) => e != null && e.toString().trim().isNotEmpty).isNotEmpty;
    }

    final complete = hasName && hasGender && hasBirthdate && hasLocation && hasInterests;

    // lưu lại flag để lần sau check nhanh hơn
    await docRef.set({'profile_completed': complete}, SetOptions(merge: true));

    return complete;
  }

  // ===== Nếu user doc chưa tồn tại -> tạo doc cơ bản (không mark completed) =====
  Future<void> initUserDocIfNeeded() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docRef = _db.collection('users').doc(user.uid);
    final snap = await docRef.get();

    if (!snap.exists) {
      await docRef.set({
        'user_id': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'avatar_url': user.photoURL ?? '',
        'location': null,
        'birthdate': null,
        'gender': null,
        'interests': [],
        'bio': '',
        'created_at': FieldValue.serverTimestamp(),
        'role': 'user',
        'profile_completed': false,
      }, SetOptions(merge: true));
    }
  }

  // ===== Logout =====
  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}
    await _auth.signOut();
  }

  Future<void> disconnect() async {
    await signOut();
  }

  // ===== Stream trạng thái login =====
  Stream<User?> get userStream => _auth.authStateChanges();
}