// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/login_screen_view.dart';
import 'views/home_screen_view.dart';
import 'views/register_screen_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Configura la barra de estado transparente con íconos oscuros
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Barra de estado transparente
    statusBarIconBrightness: Brightness.dark, // Íconos oscuros
    systemNavigationBarColor: Colors.white, // Barra de navegación inferior blanca
    systemNavigationBarIconBrightness: Brightness.dark, // Íconos oscuros en la barra inferior
  ));

  // Permite renderizar en toda la pnatalla
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // Mantiene la barra de estado transparente
        statusBarColor: Colors.transparent, 
        // Asegura que los iconos de la barra de estado sean oscuros
        statusBarIconBrightness: Brightness.dark, 
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        routes: {
          "/": (context) => RegisterScreen(),
          "/login": (context) => LoginScreen(),
          "/home": (context) => HomeScreen(),
        },
        theme: ThemeData(
          // Asegura fondo blanco detrás de la barra de estado
          scaffoldBackgroundColor: Colors.white, 
        ),
      ),
    );
  }
}
