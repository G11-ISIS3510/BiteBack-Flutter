import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  // Instancia de firebase para manejar lo relacionado con autenticación
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para manejar el registro con email y contraseña
  Future<User?> registerWithEmail(String email, String password) async {
    
    try {
      // Se crea la credencial en la base de autenticacion usando la informacion del usuario
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } 
    catch (e) {
      return null;
    }
  }

  // Método para manejar el inicio de sesión con email y contraseña
  Future<User?> loginWithEmail(String email, String password) async {
    
    try {
      // Se utiliza la base de datos de autenticacion para verificar las credenciales
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email,password: password);
      return userCredential.user;
    } 
    catch (e) {
      return null;
    }
  }

  // Método para iniciar sesión con la cuenta de google
  Future<User?> signInWithGoogle() async {

    try {
      // Se verifica la autenticacion haciendo uso de los servicios de google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      // Se genera la credencial 
      final AuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken,idToken: googleAuth.idToken);

      // Se utiliza el servicio de firebase y las credenciales
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } 
    catch (e) {
      return null;
    }
  }

  // Método en construcción. Registro con número de teléfono y código
  Future<void> registerWithPhone(String phoneNumber, Function(String) codeSentCallback, Function(String) errorCallback) async {
    
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          errorCallback(e.message ?? "Error desconocido");
        },
        codeSent: (String verificationId, int? resendToken) {
          codeSentCallback(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
        },
      );
    } 
    catch (e) {
      errorCallback(e.toString());
    }
  }

  // Método en construcción. Inicio de sesión con número de teléfono y código
  Future<User?> loginWithPhone(String verificationId, String smsCode) async {

    try {
      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } 
    catch (e) {
      return null;
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {

    // Se utilizan los servicios externos para cerrar la sesisón
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
