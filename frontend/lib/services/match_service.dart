import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MatchService {
  static const String _baseUrl = 'http://localhost:4000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<List<Map<String, dynamic>>> getMatches() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final uri = Uri.parse('$_baseUrl/match/list');
      final resp = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching matches: $e');
      return [];
    }
  }

  Future<bool> swipe(String targetUid, String action) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final uri = Uri.parse('$_baseUrl/match/swipe');
      final resp = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'targetUid': targetUid,
          'action': action, // 'like' or 'dislike'
        }),
      );

      return resp.statusCode >= 200 && resp.statusCode < 300;
    } catch (e) {
      print('Error swiping: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> checkMatch(String targetUid) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final uri = Uri.parse('$_baseUrl/match/check');
      final resp = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'targetUid': targetUid,
        }),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error checking match: $e');
      return null;
    }
  }
}

