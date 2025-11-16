import 'dart:convert';
import 'api_client.dart';
import 'backend_auth_service.dart';

class ChatMessageDto {
  final String id;
  final String from;
  final String to;
  final String text;
  final DateTime createdAt;
  ChatMessageDto({required this.id, required this.from, required this.to, required this.text, required this.createdAt});
}

class ChatApi {
  static Future<List<ChatMessageDto>> getMessages(String roomId) async {
    await BackendAuthService.ensureBackendToken();
    final res = await ApiClient.get('/api/chat/$roomId');
    if (res.statusCode == 200) {
      final List<dynamic> list = jsonDecode(res.body);
      return list.map((e) {
        final ts = e['createdAt'];
        DateTime created;
        if (ts is Map && ts['_seconds'] is int) {
          created = DateTime.fromMillisecondsSinceEpoch((ts['_seconds'] as int) * 1000);
        } else {
          created = DateTime.now();
        }
        return ChatMessageDto(
          id: e['id'] as String,
          from: e['from'] as String,
          to: (e['to'] as String?) ?? '',
          text: (e['text'] as String?) ?? '',
          createdAt: created,
        );
      }).toList();
    }
    return [];
  }

  static Future<void> sendMessage(String roomId, String toUid, String text) async {
    await BackendAuthService.ensureBackendToken();
    await ApiClient.post('/api/chat/send', {
      'roomId': roomId,
      'toUid': toUid,
      'text': text,
    });
  }
}


