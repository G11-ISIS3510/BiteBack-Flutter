import 'dart:io';
import 'package:biteback/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/user_profile_model.dart';
import '../core/local_user_db.dart';
import '../repositories/user_repository.dart';


class ProfileRepository {
  final _firestore = FirebaseFirestore.instance;
  final _userRepository = UserRepository(); 

  Future<UserProfile> fetchUserProfile(String uid) async {
    final doc = await _firestore.collection("users").doc(uid).get();
    final data = doc.data();
    if (data == null) throw Exception("No user found");

    final profile = UserProfile.fromMap(data);

    // Intenta recuperar la ruta local si existe en cache
    final local = await LocalUserDB.getUserProfile(uid);
    if (local?.localProfileImagePath != null) {
      profile.localProfileImagePath = local!.localProfileImagePath;
    } else {
      profile.localProfileImagePath = await _cacheImage(profile.uid, profile.profileImageUrl);
    }




    await LocalUserDB.saveUserProfile(profile);
    return profile;
  }

  Future<UserProfile?> getLocalUserProfile(String uid) async {
    return await LocalUserDB.getUserProfile(uid);
  }

  Future<String?> _cacheImage(String uid, String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/$uid-profile.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (_) {}
    return null;
  }

  Future<void> updateUserProfileRemote(UserProfile profile) async {
    final userModel = UserModel(
      uid: profile.uid,
      email: profile.email,
      phoneNumber: profile.phoneNumber ?? "",
      profileImage: profile.profileImageUrl ?? "",
      earnedPoints: profile.earnedPoints,
      deviceModel: profile.deviceModel,
      displayName: profile.displayName,
    );

    await _userRepository.updateUserData(userModel);
  }
}


