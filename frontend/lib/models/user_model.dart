import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String? gender;
  final DateTime? birthdate;
  final List<String>? interests;
  final String? bio;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.gender,
    this.birthdate,
    this.interests,
    this.bio,
    this.role = 'user',
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'],
      name: map['name'],
      email: map['email'],
      gender: map['gender'],
      birthdate: map['birthdate'] != null ? (map['birthdate'] as Timestamp).toDate() : null,
      interests: map['interests'] != null ? List<String>.from(map['interests']) : [],
      bio: map['bio'],
      role: map['role'] ?? 'user',
      createdAt: (map['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'gender': gender,
      'birthdate': birthdate,
      'interests': interests ?? [],
      'bio': bio,
      'role': role,
      'created_at': createdAt,
    };
  }
}
