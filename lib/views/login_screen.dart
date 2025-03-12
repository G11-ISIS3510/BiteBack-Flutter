import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isRegisterMode = false;
  bool isEmailMode = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/BiteBackLogoNaranja.png', height: 50),
                SizedBox(width: 10),
                Text("Biteback", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
            SizedBox(height: 10),
            Text("Más baratos, más accesibles.", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (context) => RegisterScreen())
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRegisterMode ? Colors.orange : Colors.white,
                    foregroundColor: isRegisterMode ? Colors.white : Colors.black,
                  ),
                  child: Text("Registrarse"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => setState(() => isRegisterMode = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRegisterMode ? Colors.white : Colors.orange,
                    foregroundColor: isRegisterMode ? Colors.black : Colors.white,
                  ),
                  child: Text("Iniciar Sesión"),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            Text("Consigue tus medicamentos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Iniciar sesión con:"),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => authViewModel.loginWithGoogle(context),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/google.png', height: 20),
                        SizedBox(width: 5),
                        Text("Sign in with Google")
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => isEmailMode = !isEmailMode),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email),
                        SizedBox(width: 5),
                        Text(isEmailMode ? "Correo electrónico" : "Número de Teléfono")
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            
            isEmailMode
                ? TextField(controller: emailController, decoration: InputDecoration(labelText: "Correo Electrónico"))
                : TextField(controller: phoneController, decoration: InputDecoration(labelText: "Número de Teléfono")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Contraseña"), obscureText: true),
            
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (isEmailMode) {
                  authViewModel.loginWithEmail(emailController.text, passwordController.text, context);
                } else {
                  authViewModel.loginWithPhone(phoneController.text, context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
               child: Text("Iniciar sesión →", style: TextStyle(color: Colors.white, fontSize: 18),),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                // Implementar recuperación de contraseña
              },
              child: Text("Olvidé mi contraseña. Recuperarla", style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      ),
    );
  }
}
