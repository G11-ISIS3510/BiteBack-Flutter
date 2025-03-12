import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100),
            Text("Biteback", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Más baratos, más accesibles.", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Correo Electrónico")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Contraseña"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
  onPressed: () => authViewModel.loginWithEmail(
    emailController.text,
    passwordController.text,
    context, // <-- Agregar el tercer parámetro
  ),
  child: Text("Iniciar Sesión"),
),

            ElevatedButton(
              onPressed: () => authViewModel.loginWithGoogle(),
              child: Text("Sign in with Google"),
            ),
          ],
        ),
      ),
    );
  }
}
