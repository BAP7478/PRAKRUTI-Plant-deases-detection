class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String location;
  final String farmSize;
  final List<String> cropTypes;
  final String? profileImageUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.location,
    required this.farmSize,
    required this.cropTypes,
    this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'location': location,
      'farmSize': farmSize,
      'cropTypes': cropTypes,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      location: map['location'] ?? '',
      farmSize: map['farmSize'] ?? '',
      cropTypes: List<String>.from(map['cropTypes'] ?? []),
      profileImageUrl: map['profileImageUrl'],
    );
  }
}
