// lib/models/media_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MediaModel {
  final String mediaId;
  final String userId;
  final String url;
  final String? type; // image/video
  final DateTime? uploadedAt;

  MediaModel({
    required this.mediaId,
    required this.userId,
    required this.url,
    this.type,
    this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'media_id': mediaId,
      'user_id': userId,
      'url': url,
      'type': type ?? 'image',
      'uploaded_at': uploadedAt != null ? Timestamp.fromDate(uploadedAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory MediaModel.fromMap(Map<String, dynamic> map) {
    return MediaModel(
      mediaId: map['media_id'] ?? '',
      userId: map['user_id'] ?? '',
      url: map['url'] ?? '',
      type: map['type'] ?? 'image',
      uploadedAt: map['uploaded_at'] != null ? (map['uploaded_at'] as Timestamp).toDate() : null,
    );
  }

  factory MediaModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return MediaModel.fromMap(data);
  }
}
