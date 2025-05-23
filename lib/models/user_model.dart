class UserModel {
  final String uid;
  final String email;
  final String? phoneNumber;
  final String? profileImage;
  final int earnedPoints;
  final String? deviceModel;
  final String? displayName;

  // NUEVOS CAMPOS
  final String? deviceManufacturer;
  final String? androidVersion;
  final int? androidSdk;
  final bool? isPhysicalDevice;

  UserModel({
    required this.uid,
    required this.email,
    this.phoneNumber,
    this.profileImage,
    this.earnedPoints = 0,
    this.deviceModel,
    this.displayName,
    this.deviceManufacturer,
    this.androidVersion,
    this.androidSdk,
    this.isPhysicalDevice,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phone_number': phoneNumber ?? "",
      'profile_image': profileImage ?? "",
      'earned_points': earnedPoints,
      'device_model': deviceModel ?? "",
      'display_name': displayName ?? "",
      'device_manufacturer': deviceManufacturer ?? "",
      'android_version': androidVersion ?? "",
      'android_sdk': androidSdk ?? -1,
      'is_physical_device': isPhysicalDevice ?? false,
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
      displayName: map['display_name'],
      deviceManufacturer: map['device_manufacturer'],
      androidVersion: map['android_version'],
      androidSdk: map['android_sdk'],
      isPhysicalDevice: map['is_physical_device'],
    );
  }
}
