import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseConfig {
  static Future<void> initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }
}
