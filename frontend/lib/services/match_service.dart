import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchUser {
  final String uid;
  final String name;
  final String avatarUrl;
  final int? age;
  final String bio;
  final List<String> interests;
  final DateTime timestamp;

  MatchUser({
    required this.uid,
    required this.name,
    required this.avatarUrl,
    required this.timestamp,
    this.age,
    this.bio = '',
    this.interests = const [],
  });
}

class MatchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<MatchUser?> _getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    int? age;
    try {
      // Optional: derive age from birthdate timestamp (if present as Timestamp with seconds)
      if (data['birthdate'] != null && data['birthdate'] is Timestamp) {
        final DateTime dob = (data['birthdate'] as Timestamp).toDate();
        final now = DateTime.now();
        age = now.year - dob.year - ((now.month < dob.month || (now.month == dob.month && now.day < dob.day)) ? 1 : 0);
      }
    } catch (_) {}
    return MatchUser(
      uid: uid,
      name: (data['name'] as String?)?.trim().isNotEmpty == true ? data['name'] : 'Người dùng',
      avatarUrl: (data['avatar_url'] as String?) ?? '',
      bio: (data['bio'] as String?) ?? '',
      interests: (data['interests'] is List) ? List<String>.from(data['interests']) : const [],
      age: age,
      timestamp: DateTime.now(),
    );
  }

  /// Likes involving current user (both sent and received), action == 'like'
  Future<List<MatchUser>> getAllLikes() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    final uid = user.uid;

    final sent = await _db
        .collection('matches')
        .where('from', isEqualTo: uid)
        .where('action', isEqualTo: 'like')
        .orderBy('createdAt', descending: true)
        .get();

    final received = await _db
        .collection('matches')
        .where('to', isEqualTo: uid)
        .where('action', isEqualTo: 'like')
        .orderBy('createdAt', descending: true)
        .get();

    final List<_LikeEntry> entries = [];
    for (final d in sent.docs) {
      final data = d.data();
      entries.add(_LikeEntry(
        otherUid: data['to'] as String,
        createdAt: (data['createdAt'] is Timestamp) ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
      ));
    }
    for (final d in received.docs) {
      final data = d.data();
      entries.add(_LikeEntry(
        otherUid: data['from'] as String,
        createdAt: (data['createdAt'] is Timestamp) ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
      ));
    }

    // Fetch distinct users
    final seen = <String, DateTime>{};
    for (final e in entries) {
      final existing = seen[e.otherUid];
      if (existing == null || e.createdAt.isAfter(existing)) {
        seen[e.otherUid] = e.createdAt;
      }
    }
    final List<MatchUser> result = [];
    for (final entry in seen.entries) {
      final userData = await _getUser(entry.key);
      if (userData != null) {
        result.add(MatchUser(
          uid: userData.uid,
          name: userData.name,
          avatarUrl: userData.avatarUrl,
          bio: userData.bio,
          interests: userData.interests,
          age: userData.age,
          timestamp: entry.value,
        ));
      }
    }
    // Sort by timestamp desc
    result.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return result;
  }

  /// Mutual matches are chat rooms documents in 'matches' with users array containing current uid
  Future<List<MatchUser>> getMutualMatches() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    final uid = user.uid;
    final snaps = await _db
        .collection('matches')
        .where('users', arrayContains: uid)
        .orderBy('matchedAt', descending: true)
        .get();
    final List<MatchUser> result = [];
    for (final d in snaps.docs) {
      final data = d.data();
      if (data['users'] is List && (data['users'] as List).length == 2) {
        final List<dynamic> users = data['users'];
        final String otherUid = users[0] == uid ? users[1] as String : users[0] as String;
        final matchedAt = (data['matchedAt'] is Timestamp) ? (data['matchedAt'] as Timestamp).toDate() : DateTime.now();
        final userData = await _getUser(otherUid);
        if (userData != null) {
          result.add(MatchUser(
            uid: userData.uid,
            name: userData.name,
            avatarUrl: userData.avatarUrl,
            bio: userData.bio,
            interests: userData.interests,
            age: userData.age,
            timestamp: matchedAt,
          ));
        }
      }
    }
    return result;
  }
}

class _LikeEntry {
  final String otherUid;
  final DateTime createdAt;
  _LikeEntry({required this.otherUid, required this.createdAt});
}


