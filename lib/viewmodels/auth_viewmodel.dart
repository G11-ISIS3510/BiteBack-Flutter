// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {

  // Servicio de autenticación
  final AuthService _authService = AuthService(); 

  // Variables de clase
  User? _user; 
  bool _isLoading = false; 
  String? verificationId; 

  // Getters para exponer los valores
  User? get user => _user;
  bool get isLoading => _isLoading;

  // Iniciar sesión con correo y contraseña
  Future<void> loginWithEmail(String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    // Se consume el servicio de login
    _user = await _authService.loginWithEmail(email, password);
    
    _isLoading = false;
    notifyListeners();

    // Navegación hacia la pantalla principal
    if (_user != null) {
      Navigator.pushReplacementNamed(context, "/home"); 
    } 
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar sesión"))
      );
    }
  }

  // Método para registrar usuario con correo y contraseña
  Future<void> registerWithEmail(String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    // Se consume el servicio de registro
    _user = await _authService.registerWithEmail(email, password);
    
    _isLoading = false;
    notifyListeners();

    // Navegación hacia la pantalla principal
    if (_user != null) {
      Navigator.pushReplacementNamed(context, "/home"); 
    } 
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al registrar usuario"))
      );
    }
  }

  // Método para iniciar sesión con google
  Future<void> loginWithGoogle(BuildContext context) async {
    
    _isLoading = true;
    notifyListeners();

    // Se consume el servicio de registro
    _user = await _authService.signInWithGoogle();
    
    _isLoading = false;
    notifyListeners();

    // Navegación hacia la pantalla principal
    if (_user != null) {
      Navigator.pushReplacementNamed(context, "/home"); 
    } 
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar sesión"))
      );
    }
  }

  // Método en construcción. Registrar usuario con número de teléfono
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

  // Método en construcción. Iniciar sesión con código SMS
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
    } 
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar sesión con teléfono"))
      );
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
