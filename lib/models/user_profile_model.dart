class UserProfile {
  final String uid;
  String email;
  String? phoneNumber;
  String? profileImageUrl;
  String? localProfileImagePath;
  int earnedPoints;
  String? deviceModel;
  String? displayName;


  UserProfile({
    required this.uid,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.localProfileImagePath,
    this.earnedPoints = 0,
    this.deviceModel, 
    this.displayName,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phone_number': phoneNumber,
      'profile_image_url': profileImageUrl,
      'local_image_path': localProfileImagePath,
      'earned_points': earnedPoints,
      'device_model': deviceModel,
      'display_name': displayName ?? '',

    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'],
      email: map['email'],
      phoneNumber: map['phone_number'],
      profileImageUrl: map['profile_image_url'],
      localProfileImagePath: map['local_image_path'],
      earnedPoints: map['earned_points'] ?? 0,
      deviceModel: map['device_model'],
      displayName: map['display_name'],

    );
  }
}
