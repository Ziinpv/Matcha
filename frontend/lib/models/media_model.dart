import 'package:cloud_firestore/cloud_firestore.dart';

class Media {
  final String mediaId;
  final String userId;
  final String url;
  final String type;
  final DateTime uploadedAt;

  Media({
    required this.mediaId,
    required this.userId,
    required this.url,
    required this.type,
    required this.uploadedAt,
  });

  factory Media.fromMap(Map<String, dynamic> map) {
    return Media(
      mediaId: map['media_id'],
      userId: map['user_id'],
      url: map['url'],
      type: map['type'],
      uploadedAt: (map['uploaded_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'media_id': mediaId,
      'user_id': userId,
      'url': url,
      'type': type,
      'uploaded_at': uploadedAt,
    };
  }
}
