import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Đăng nhập bằng email/password
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

  // Đăng ký email/password
  Future<User?> registerWithEmail(String email, String password, String name) async {
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCred.user;

      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'user_id': user.uid,
          'name': name,
          'email': email,
          'created_at': DateTime.now(),
          'role': 'user',
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print("Error register: $e");
      throw e;
    }
  }

  // Đăng nhập bằng Google
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
            'created_at': DateTime.now(),
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

  // Đăng nhập bằng Google (alias cho loginWithGoogle để giữ tính tương thích)
  Future<User?> loginWithGoogle() async {
    return await signInWithGoogle();
  }

  // Logout toàn bộ
  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect(); // Google chọn lại account lần sau
    } catch (_) {}
    await _auth.signOut();
  }

  // Đăng xuất hẳn (Firebase + Google) - alias cho signOut
  Future<void> disconnect() async {
    await signOut();
  }

  // Link email/password với tài khoản Google (tùy chọn)
  Future<void> linkEmailPassword(User user, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.linkWithCredential(credential);
    } catch (e) {
      print("Error linking email password: $e");
      throw e;
    }
  }

  // Stream theo dõi trạng thái đăng nhập
  Stream<User?> get userStream => _auth.authStateChanges();
}