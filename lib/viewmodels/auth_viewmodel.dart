import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? verificationId;

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
      );
    }

  }

  Future<void> registerWithEmail(String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    _user = await _authService.registerWithEmail(email, password);
    _isLoading = false;
    notifyListeners();

    if (_user != null) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al registrar usuario"))
      );}}

  Future<void> loginWithGoogle(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    _user = await _authService.signInWithGoogle();
    _isLoading = false;
    notifyListeners();

    if (_user != null) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar sesión"))
      );
    }
  }

  Future<void> registerWithPhone(String phoneNumber, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    await _authService.registerWithPhone(
      phoneNumber,
      (String verId) {
        verificationId = verId;
        notifyListeners();
      },
      (String errorMsg) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $errorMsg"))
        );
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithPhone(String smsCode, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    if (verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Código de verificación no encontrado."))
      );
      return;
    }

    _user = await _authService.loginWithPhone(verificationId!, smsCode);
    
    _isLoading = false;
    notifyListeners();

    if (_user != null) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar sesión con teléfono"))
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
