// ignore_for_file: use_build_context_synchronously

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

    // Intentar el login
    String? errorMessage = await _authService.loginWithEmail(email, password);

    if (errorMessage == null) {
      Navigator.pushReplacementNamed(context, "/home"); 
    } else {
      _showError(context, errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> registerWithEmail(String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    // Intentar el registro
    String? errorMessage = await _authService.registerWithEmail(email, password);

    if (errorMessage == null) {
      Navigator.pushReplacementNamed(context, "/home"); 
    } else {
      _showError(context, errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    // Intentar el login con Google
    String? errorMessage = await _authService.signInWithGoogle();

    if (errorMessage == null) {
      Navigator.pushReplacementNamed(context, "/home"); 
    } else {
      _showError(context, errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> registerWithPhone(String phoneNumber, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    // Intentar el registro con teléfono
    String? errorMessage = await _authService.registerWithPhone(
      phoneNumber,
      (String verId) {
        verificationId = verId;
        notifyListeners();
      },
      (String errorMsg) {
        _showError(context, errorMsg);
      },
    );

    if (errorMessage != null) {
      _showError(context, errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithPhone(String smsCode, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    if (verificationId == null) {
      _showError(context, "Código de verificación no encontrado.");
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Intentar el login con teléfono
    String? errorMessage = await _authService.loginWithPhone(verificationId!, smsCode);

    if (errorMessage == null) {
      Navigator.pushReplacementNamed(context, "/home"); 
    } else {
      _showError(context, errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  void _showError(BuildContext context, String message) {
    final cleanedMessage = message.replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(cleanedMessage)),
    );
  }
}
