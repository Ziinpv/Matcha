import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_client.dart';

class BackendAuthService {
  static bool _loggingIn = false;

  static Future<void> ensureBackendToken() async {
    if (_loggingIn) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_hasToken()) return;

    _loggingIn = true;
    try {
      final res = await ApiClient.post('/api/auth/login', {
        'uid': user.uid,
        'email': user.email ?? '',
      }, auth: false);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data['token'] is String) {
          ApiClient.setToken(data['token'] as String);
        }
      }
    } finally {
      _loggingIn = false;
    }
  }

  static bool _hasToken() {
    // naive check; ApiClient keeps token in memory
    // If needed, persist to storage.
    return false;
  }
}


