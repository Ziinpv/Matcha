import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static const String _baseUrl = 'http://localhost:4000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<Map<String, dynamic>?> sendMessage({
    required String roomId,
    required String toUid,
    required String text,
    String? imageUrl,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('❌ ChatService: No token found');
        return null;
      }

      final uri = Uri.parse('$_baseUrl/chat/send');
      final body = jsonEncode({
        'roomId': roomId,
        'toUid': toUid,
        'text': text,
        if (imageUrl != null) 'imageUrl': imageUrl,
      });

      print('📤 Sending message: roomId=$roomId, toUid=$toUid, text=${text.substring(0, text.length > 20 ? 20 : text.length)}...');

      final resp = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('📥 Response status: ${resp.statusCode}');
      print('📥 Response body: ${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      } else {
        print('❌ Error response: ${resp.statusCode} - ${resp.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ Error sending message: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(String roomId) async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final uri = Uri.parse('$_baseUrl/chat/$roomId');
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
      print('Error fetching messages: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentChats() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final uri = Uri.parse('$_baseUrl/chat/list');
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
      print('Error fetching recent chats: $e');
      return [];
    }
  }

  Future<bool> markAsRead(String roomId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final uri = Uri.parse('$_baseUrl/chat/mark-read');
      final body = jsonEncode({
        'roomId': roomId,
      });

      final resp = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      return resp.statusCode >= 200 && resp.statusCode < 300;
    } catch (e) {
      print('Error marking as read: $e');
      return false;
    }
  }
}

