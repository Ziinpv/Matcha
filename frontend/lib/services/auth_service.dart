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
          'created_at': FieldValue.serverTimestamp(),
          'role': 'user',
        });
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
            'location': null, // user tự nhập trong profile
            'created_at': FieldValue.serverTimestamp(),
            'role': 'user',
          });
        }
      }

      return user;
    } catch (e) {
      print("Error google login: $e");
      return null;
    }
  }

  // Alias cho loginWithGoogle
  Future<User?> loginWithGoogle() async {
    return await signInWithGoogle();
  }

  // ===== Cập nhật thông tin profile (Firestore) =====
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection("users").doc(user.uid).update(data);
    }
  }

  // ===== Logout =====
  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect(); // Bắt buộc chọn lại account lần sau
    } catch (_) {}
    await _auth.signOut();
  }

  Future<void> disconnect() async {
    await signOut();
  }

  // ===== Quên mật khẩu (chỉ áp dụng cho email/password) =====
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ===== Xóa user cả Firestore + FirebaseAuth =====
  Future<void> deleteUserCompletely() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    await _db.collection("users").doc(user.uid).delete();
    await user.delete();
  }

  // ===== Stream trạng thái login =====
  Stream<User?> get userStream => _auth.authStateChanges();
}
