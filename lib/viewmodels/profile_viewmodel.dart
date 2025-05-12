import 'package:biteback/core/local_user_db.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile_model.dart';
import '../repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();
  UserProfile? _profile;
  bool _isLoading = true;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;

  ProfileViewModel() {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      _profile = await _repository.fetchUserProfile(uid);
    } catch (_) {
      _profile = await _repository.getLocalUserProfile(uid);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfileChanges() async {
  if (_profile == null) return;
  try {
    await _repository.updateUserProfileRemote(_profile!);     // 1. Guardar en Firestore
    await LocalUserDB.saveUserProfile(_profile!);              // 2. Actualizar local
  } catch (e) {
    // Puedes manejar errores aquí si quieres
    print("Error al guardar perfil: $e");
  }
}

}
