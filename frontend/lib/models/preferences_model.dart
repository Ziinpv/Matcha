class Preferences {
  final String prefId;
  final String userId;
  final String? preferredGender;
  final int? minAge;
  final int? maxAge;
  final int? distanceKm;
  final bool showMe;

  Preferences({
    required this.prefId,
    required this.userId,
    this.preferredGender,
    this.minAge,
    this.maxAge,
    this.distanceKm,
    this.showMe = true,
  });

  factory Preferences.fromMap(Map<String, dynamic> map) {
    return Preferences(
      prefId: map['pref_id'],
      userId: map['user_id'],
      preferredGender: map['preferred_gender'],
      minAge: map['min_age'],
      maxAge: map['max_age'],
      distanceKm: map['distance_km'],
      showMe: map['show_me'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pref_id': prefId,
      'user_id': userId,
      'preferred_gender': preferredGender,
      'min_age': minAge,
      'max_age': maxAge,
      'distance_km': distanceKm,
      'show_me': showMe,
    };
  }
}
