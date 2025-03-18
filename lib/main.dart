import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/login_screen_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/home_screen_view.dart';
import 'views/register_screen_view.dart';

import 'viewmodels/product_viewmodel.dart';
import 'views/product_detail_view.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
  
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => AuthViewModel()),
//       ],
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       initialRoute: "/",
//       routes: {
//         "/": (context) => RegisterScreen(),
//         "/login": (context) => LoginScreen(),
//         "/home": (context) => HomeScreen(), 
//       },
//     );
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ProductDetailView(productId: "product_001"), // Test Detail View
    );
  }
}