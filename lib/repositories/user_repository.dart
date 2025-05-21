import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<void> createUserDocumentIfNotExists(User user) async {
    final docRef = _firestore.collection("users").doc(user.uid);
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) return;

    final deviceInfo = DeviceInfoPlugin();
    String deviceModel = "Unknown";
    String deviceManufacturer = "Unknown";
    String androidVersion = "Unknown";
    int androidSdk = -1;
    bool isPhysicalDevice = false;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceModel = androidInfo.model;
      deviceManufacturer = androidInfo.manufacturer;
      androidVersion = androidInfo.version.release ?? "Unknown";
      androidSdk = androidInfo.version.sdkInt;
      isPhysicalDevice = androidInfo.isPhysicalDevice;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceModel = iosInfo.utsname.machine;
      deviceManufacturer = "Apple";
      androidVersion = iosInfo.systemVersion ?? "Unknown";
      isPhysicalDevice = iosInfo.isPhysicalDevice;
    }

    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? "",
      phoneNumber: user.phoneNumber ?? "",
      profileImage: "",
      earnedPoints: 0,
      deviceModel: deviceModel,
      displayName: null,
      deviceManufacturer: deviceManufacturer,
      androidVersion: androidVersion,
      androidSdk: androidSdk,
      isPhysicalDevice: isPhysicalDevice,
    );

    await docRef.set(userModel.toMap());
  }

  Future<void> updateUserData(UserModel user) async {
    final docRef = _firestore.collection("users").doc(user.uid);
    await docRef.update(user.toMap());
  }
}
