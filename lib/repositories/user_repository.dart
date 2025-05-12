import 'dart:io';
import 'package:biteback/models/user_profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class UserRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<void> createUserDocumentIfNotExists(User user) async {
    final docRef = _firestore.collection("users").doc(user.uid);
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) return;

    final deviceInfo = DeviceInfoPlugin();
    String deviceModel = "Unknown";

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceModel = androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceModel = iosInfo.utsname.machine;
    }

    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? "",
      phoneNumber: user.phoneNumber ?? "",
      profileImage: "",
      earnedPoints: 0,
      deviceModel: deviceModel,
    );

    await docRef.set(userModel.toMap());
  }

  Future<void> updateUserData(UserModel user) async {
    final docRef = _firestore.collection("users").doc(user.uid);
    await docRef.update(user.toMap());
  }

  Future<void> updateUserProfileRemote(UserProfile profile) async {
    String? downloadUrl;

    // Subimos imagen si hay local
    if (profile.localProfileImagePath != null) {
      final file = File(profile.localProfileImagePath!);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("profile_images/${profile.uid}.jpg");

      final uploadTask = await storageRef.putFile(file);
      downloadUrl = await uploadTask.ref.getDownloadURL();

      profile.profileImageUrl = downloadUrl;
    }

    final userModel = UserModel(
      uid: profile.uid,
      email: profile.email,
      phoneNumber: profile.phoneNumber ?? "",
      profileImage: profile.profileImageUrl ?? "",
      earnedPoints: profile.earnedPoints,
      deviceModel: profile.deviceModel,
      displayName: profile.displayName,
    );

    await updateUserData(userModel); // ← CORREGIDO: sin _userRepository
  }
}
