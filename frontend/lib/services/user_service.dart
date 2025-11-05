import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _baseUrl = 'http://localhost:4000/api';

  Future<bool> getProfileStatus() async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/user/profile-status');
    final resp = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return (data['profileComplete'] as bool?) ?? false;
    }
    return false;
  }

  Future<bool> completeProfile(Map<String, dynamic> payload) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('❌ UserService: No token found');
        return false;
      }
      
      final uri = Uri.parse('$_baseUrl/user/complete-profile');
      print('📤 POST to $_baseUrl/user/complete-profile');
      
      final resp = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      
      print('📥 Response status: ${resp.statusCode}');
      
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        print('✅ completeProfile successful');
        return true;
      } else {
        print('❌ completeProfile failed: ${resp.statusCode}');
        print('   Response body: ${resp.body}');
        try {
          final errorData = jsonDecode(resp.body) as Map<String, dynamic>;
          print('   Error details: $errorData');
        } catch (_) {}
        return false;
      }
    } catch (e) {
      print('❌ Error in completeProfile: $e');
      return false;
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
}


