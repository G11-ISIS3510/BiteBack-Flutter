import 'package:biteback/models/product_model.dart';
import 'package:biteback/views/profile_screen.dart';
import 'package:biteback/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/cart_screen.dart';
import 'views/home_screen_view.dart';
import 'views/auth_screen.dart';
import 'services/navigation_service.dart';
import 'views/product_detail_screen.dart';
import 'views/mystery_box_view.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: NavigationService().navigatorKey,
        
        initialRoute: "/",
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            case '/login':
              return MaterialPageRoute(builder: (_) => const AuthScreen(isRegister: false));
            case '/home':
              return MaterialPageRoute(builder: (_) => HomeScreen());
            case '/cart':
              return MaterialPageRoute(builder: (_) => const CartScreen());
            case '/profile':
              return MaterialPageRoute(builder: (_) => const ProfileScreen());
            case '/mystery':
              return MaterialPageRoute(builder: (_) => const MysteryBoxView());
            
            case '/productDetail':
              final product = settings.arguments as Product;
              return MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text("Ruta no encontrada")),
                ),
              );
          }
        },

        themeMode: themeProvider.themeMode,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _updateThemeBasedOnTime();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void _updateThemeBasedOnTime() {
    final hour = DateTime.now().hour;
    if (hour >= 18 || hour < 6) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }
}
