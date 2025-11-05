import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackendAuthService {
  static const String _baseUrl = 'http://localhost:4000/api'; // sync with backend server.js
  static const String _tokenKey = 'jwt_token';

  Future<String?> issueJwtFromBackend(User user) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    final resp = await http.post(
      uri,
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode({ 'uid': user.uid, 'email': user.email }),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
      }
      return token;
    }
    return null;
  }

  Future<String?> getStoredJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearJwt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}


