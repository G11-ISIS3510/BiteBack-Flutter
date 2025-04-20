class UserModel {
  final String uid;
  final String email;
  final String? phoneNumber;
  final String? profileImage;
  final int earnedPoints;
  final String? deviceModel;

  UserModel({
    required this.uid,
    required this.email,
    this.phoneNumber,
    this.profileImage,
    this.earnedPoints = 0,
    this.deviceModel,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phone_number': phoneNumber ?? "",
      'profile_image': profileImage ?? "",
      'earned_points': earnedPoints,
      'device_model': deviceModel ?? "",
      'created_at': DateTime.now(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      phoneNumber: map['phone_number'],
      profileImage: map['profile_image'],
      earnedPoints: map['earned_points'] ?? 0,
      deviceModel: map['device_model'],
    );
  }
}
