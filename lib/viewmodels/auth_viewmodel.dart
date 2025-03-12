import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> loginWithEmail(String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    _user = await _authService.loginWithEmail(email, password);
    
    _isLoading = false;
    notifyListeners();

    if (_user != null) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar sesión"))
      );}}

  Future<void> registerWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    _user = await _authService.registerWithEmail(email, password);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    _user = await _authService.signInWithGoogle();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
