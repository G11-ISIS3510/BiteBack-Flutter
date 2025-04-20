// ignore_for_file: unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';

class AuthService {

  // Instancia de firebase para manejar lo relacionado con autenticación
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para manejar el registro con email y contraseña
  Future<String?> registerWithEmail(String email, String password) async {
    try {
      // Se crea la credencial en la base de autenticacion usando la informacion del usuario
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // No error
    } 
    on SocketException {
      return "No hay conexión a internet. Intenta nuevamente más tarde.";
    }
    on FirebaseAuthException catch (e) {
      return _parseFirebaseError(e);
    }
    catch (e) {
      return "No hay conexión a internet. Intenta nuevamente más tarde.";
    }
  }

  // Método para manejar el inicio de sesión con email y contraseña
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      // Se utiliza la base de datos de autenticacion para verificar las credenciales
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // No error
    } 
    on SocketException {
      return "No hay conexión a internet. Intenta nuevamente más tarde.";
    }
    on FirebaseAuthException catch (e) {
      return _parseFirebaseError(e);
    }
    catch (e) {
      return "No hay conexión a internet. Intenta nuevamente más tarde.";
    }
  }

  // Método para iniciar sesión con la cuenta de google
  Future<String?> signInWithGoogle() async {
    try {
      // Se verifica la autenticacion haciendo uso de los servicios de google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      // Se genera la credencial 
      final AuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      // Se utiliza el servicio de firebase y las credenciales
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return null; // No error
    } 
    on SocketException {
      return "No hay conexión a internet. Intenta nuevamente más tarde.";
    }
    on FirebaseAuthException catch (e) {
      return _parseFirebaseError(e);
    }
    catch (e) {
      return "No hay conexión a internet. Intenta nuevamente más tarde.";
    }
  }

  // Método para registrar con teléfono y código
  Future<String?> registerWithPhone(String phoneNumber, Function(String) codeSentCallback, Function(String) errorCallback) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          errorCallback(_parseFirebaseError(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          codeSentCallback(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
      return null; // No error
    } 
    on SocketException {
      return "Sin conexión a internet";
    }
    catch (e) {
      return "No hay conexión a internet. Intenta nuevamente más tarde.";
    }
  }

  // Método para login con teléfono y código
  Future<String?> loginWithPhone(String verificationId, String smsCode) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return null; // No error
    } 
    on SocketException {
      return "No hay conexión a internet. Intenta nuevamente más tarde.";
    }
    on FirebaseAuthException catch (e) {
      return _parseFirebaseError(e);
    }
    catch (e) {
      return "No hay conexión a internet. Intenta nuevamente más tarde.";
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  // Helper para analizar los errores de Firebase
  String _parseFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return "No hay conexión a internet. Intenta nuevamente más tarde.";
      case 'email-already-in-use':
        return "Este correo ya está registrado.";
      case 'invalid-email':
        return "El correo no es válido.";
      case 'weak-password':
        return "La contraseña es muy débil.";
      case 'user-not-found':
        return "Usuario no encontrado.";
      case 'wrong-password':
        return "Contraseña incorrecta.";
      default:
        return e.message ?? "Error de autenticación.";
    }
  }
}
