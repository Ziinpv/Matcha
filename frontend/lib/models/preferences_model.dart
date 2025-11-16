// lib/models/preferences_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PreferencesModel {
  final String prefId;
  final String userId;
  final String? preferredGender;
  final int? minAge;
  final int? maxAge;
  final int? distanceKm;
  final bool? showMe;

  PreferencesModel({
    required this.prefId,
    required this.userId,
    this.preferredGender,
    this.minAge,
    this.maxAge,
    this.distanceKm,
    this.showMe,
  });

  Map<String, dynamic> toMap() {
    return {
      'pref_id': prefId,
      'user_id': userId,
      'preferred_gender': preferredGender ?? '',
      'min_age': minAge,
      'max_age': maxAge,
      'distance_km': distanceKm,
      'show_me': showMe ?? true,
    };
  }

  factory PreferencesModel.fromMap(Map<String, dynamic> map) {
    return PreferencesModel(
      prefId: map['pref_id'] ?? '',
      userId: map['user_id'] ?? '',
      preferredGender: (map['preferred_gender'] as String?)?.isNotEmpty == true ? map['preferred_gender'] : null,
      minAge: map['min_age'],
      maxAge: map['max_age'],
      distanceKm: map['distance_km'],
      showMe: map['show_me'] ?? true,
    );
  }

  factory PreferencesModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return PreferencesModel.fromMap(data);
  }
}
