class BlockedUser {
  final String id;
  final String username;
  final String email;
  final String? profileImageUrl;
  final DateTime blockedAt;
  final String? reason;

  BlockedUser({
    required this.id,
    required this.username,
    required this.email,
    this.profileImageUrl,
    required this.blockedAt,
    this.reason,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      blockedAt: DateTime.parse(json['blockedAt']),
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'blockedAt': blockedAt.toIso8601String(),
      'reason': reason,
    };
  }

  BlockedUser copyWith({
    String? id,
    String? username,
    String? email,
    String? profileImageUrl,
    DateTime? blockedAt,
    String? reason,
  }) {
    return BlockedUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      blockedAt: blockedAt ?? this.blockedAt,
      reason: reason ?? this.reason,
    );
  }
}
