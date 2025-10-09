// lib/services/media_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/media_model.dart';

class MediaService {
  final _mediaRef = FirebaseFirestore.instance.collection('media');

  Future<void> saveMedia(MediaModel media) async {
    await _mediaRef.doc(media.mediaId).set(media.toMap());
  }

  Future<void> deleteMedia(String mediaId) async {
    await _mediaRef.doc(mediaId).delete();
  }
  Future<void> addMedia(MediaModel media) async {
    await _mediaRef.doc(media.mediaId).set(media.toMap());
  }

  Stream<List<MediaModel>> getUserMedia(String userId) {
    return _mediaRef
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => MediaModel.fromSnapshot(doc)).toList());
  }
}
