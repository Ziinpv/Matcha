import 'dart:convert';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_client.dart';
import 'backend_auth_service.dart';

class MatchApi {
  static Future<void> swipe(String targetUid, String action) async {
    try {
      await BackendAuthService.ensureBackendToken();
      final res = await ApiClient.post('/api/match/swipe', {
        'targetUid': targetUid,
        'action': action,
      });
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Swipe failed: ${res.statusCode}');
      }
    } on TimeoutException catch (e) {
      // Silently fail on timeout - user can retry later
      // The swipe action is already visually completed
      throw e;
    } catch (e) {
      // Re-throw to let caller handle
      throw Exception('Swipe error: $e');
    }
  }

  static Future<MatchCheckResult> check(String targetUid) async {
    try {
      await BackendAuthService.ensureBackendToken();
      final res = await ApiClient.post('/api/match/check', {
        'targetUid': targetUid,
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final matched = data['matched'] == true;
        final roomId = matched ? (data['roomId'] as String?) : null;
        if (matched && (roomId == null || roomId.isEmpty)) {
          // derive fallback room id
          final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
          final sorted = [uid, targetUid]..sort();
          return MatchCheckResult(matched: true, roomId: 'room_${sorted.join('_')}');
        }
        return MatchCheckResult(matched: matched, roomId: roomId);
      }
      return MatchCheckResult(matched: false);
    } on TimeoutException {
      // Return false on timeout - no match detected
      return MatchCheckResult(matched: false);
    } catch (e) {
      // Return false on any error
      return MatchCheckResult(matched: false);
    }
  }
}

class MatchCheckResult {
  final bool matched;
  final String? roomId;
  MatchCheckResult({required this.matched, this.roomId});
}


