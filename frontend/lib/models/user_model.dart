import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  String? name;
  String? gender;
  String? bio;
  String? avatarUrl;
  DateTime? birthdate;
  String? location;
  List<String>? interests;
  bool profileCompleted;
  DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.gender,
    this.bio,
    this.avatarUrl,
    this.birthdate,
    this.location,
    this.interests,
    this.createdAt,
    this.profileCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': uid,
      'email': email,
      'name': name ?? '',
      'gender': gender ?? '',
      'bio': bio ?? '',
      'avatar_url': avatarUrl ?? '',
      'birthdate': birthdate != null ? Timestamp.fromDate(birthdate!) : null,
      'location': location ?? '',
      'interests': interests ?? [],
      'profile_completed': profileCompleted,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return UserModel(
      uid: map['user_id'] ?? docId ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      gender: map['gender'],
      bio: map['bio'],
      avatarUrl: map['avatar_url'],
      birthdate: map['birthdate'] != null
          ? (map['birthdate'] as Timestamp).toDate()
          : null,
      location: map['location'],
      interests: map['interests'] != null ? List<String>.from(map['interests']) : [],
      profileCompleted: map['profile_completed'] == true,
      createdAt: map['created_at'] != null
          ? (map['created_at'] as Timestamp).toDate()
          : null,
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, docId: snap.id);
  }
}
