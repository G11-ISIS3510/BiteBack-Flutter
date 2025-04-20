import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/user_model.dart';
import 'dart:io';

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
    deviceModel = androidInfo.model ?? "Unknown Android";
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    deviceModel = iosInfo.utsname.machine ?? "Unknown iOS";
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

}
