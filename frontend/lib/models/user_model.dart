// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;

  String? name;
  String? passwordHash;
  String? gender;
  DateTime? birthdate;
  List<String>? interests;
  String? bio;
  String? role;
  String? location;
  String? avatarUrl;
  DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.passwordHash,
    this.gender,
    this.birthdate,
    this.interests,
    this.bio,
    this.role,
    this.location,
    this.avatarUrl,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': uid, // đồng bộ với Firestore
      'email': email,
      'name': name ?? '',
      'password_hash': passwordHash,
      'gender': gender ?? '',
      'birthdate': birthdate != null ? Timestamp.fromDate(birthdate!) : null,
      'interests': interests ?? [],
      'bio': bio ?? '',
      'role': role ?? 'user',
      'location': location ?? '',
      'avatar_url': avatarUrl ?? '',
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return UserModel(
      uid: map['user_id'] ?? docId ?? '', // ưu tiên user_id, fallback docId
      email: map['email'] ?? '',
      name: (map['name'] as String?)?.isNotEmpty == true ? map['name'] : null,
      passwordHash: map['password_hash'],
      gender: (map['gender'] as String?)?.isNotEmpty == true ? map['gender'] : null,
      birthdate: map['birthdate'] != null ? (map['birthdate'] as Timestamp).toDate() : null,
      interests: map['interests'] != null ? List<String>.from(map['interests']) : null,
      bio: (map['bio'] as String?)?.isNotEmpty == true ? map['bio'] : null,
      role: map['role'] ?? 'user',
      location: (map['location'] as String?)?.isNotEmpty == true ? map['location'] : null,
      avatarUrl: (map['avatar_url'] as String?)?.isNotEmpty == true ? map['avatar_url'] : null,
      createdAt: map['created_at'] != null ? (map['created_at'] as Timestamp).toDate() : null,
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, docId: snap.id);
  }
}
