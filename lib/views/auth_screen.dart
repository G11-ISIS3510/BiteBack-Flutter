import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class AuthScreen extends StatefulWidget {
  final bool isRegister;

  const AuthScreen({Key? key, required this.isRegister}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isRegisterMode = false;
  bool isEmailMode = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController smsCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isRegisterMode = widget.isRegister;
  }

@override
Widget build(BuildContext context) {
  final authViewModel = Provider.of<AuthViewModel>(context);

  return Scaffold(
    body: Center( // ✅ Centra todo el contenido
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // ✅ Centra el contenido en la pantalla
          mainAxisSize: MainAxisSize.min, // Evita que el Column ocupe toda la pantalla
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildAuthSwitcher(),
            const SizedBox(height: 20),
            _buildSocialButtons(authViewModel),
            const SizedBox(height: 10),
            _buildFormContainer(authViewModel), // Formulario con tamaño fijo
          ],
        ),
      ),
    ),
  );
}


  /// ✅ 1️⃣ Encabezado con logo y título, permanece FIJO
  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/BiteBackLogoNaranja.png', height: 50),
            const SizedBox(width: 10),
            const Text("Biteback", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
          ],
        ),
        const SizedBox(height: 10),
        const Text("Más baratos, más accesibles.", style: TextStyle(fontSize: 16)),
      ],
    );
  }

  /// ✅ 2️⃣ Selector de "Iniciar Sesión" y "Registrarse"
  Widget _buildAuthSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => setState(() => isRegisterMode = true),
          style: ElevatedButton.styleFrom(
            backgroundColor: isRegisterMode ? Colors.orange : Colors.white,
            foregroundColor: isRegisterMode ? Colors.white : Colors.black,
          ),
          child: const Text("Registrarse"),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => setState(() => isRegisterMode = false),
          style: ElevatedButton.styleFrom(
            backgroundColor: isRegisterMode ? Colors.white : Colors.orange,
            foregroundColor: isRegisterMode ? Colors.black : Colors.white,
          ),
          child: const Text("Iniciar Sesión"),
        ),
      ],
    );
  }

  /// ✅ 3️⃣ Botones de Google y Email (Permanecen Fijos)
  Widget _buildSocialButtons(AuthViewModel authViewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => authViewModel.loginWithGoogle(context),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/google.png', height: 20),
                const SizedBox(width: 5),
                const Text("Google"),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => isEmailMode = !isEmailMode),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email),
                const SizedBox(width: 5),
                Text(isEmailMode ? "Correo" : "Teléfono"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ✅ 4️⃣ Contenedor Fijo para el Formulario
  Widget _buildFormContainer(AuthViewModel authViewModel) {
    return SizedBox(
      height: 240, // Se fija la altura del formulario para que no haya movimientos
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isRegisterMode ? _buildRegisterForm(authViewModel) : _buildLoginForm(authViewModel),
      ),
    );
  }

  /// 🔹 Formulario de Inicio de Sesión
  Widget _buildLoginForm(AuthViewModel authViewModel) {
    return Column(
      key: const ValueKey(1),
      children: [
        TextField(controller: emailController, decoration: const InputDecoration(labelText: "Correo Electrónico")),
        TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Contraseña"), obscureText: true),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => authViewModel.loginWithEmail(emailController.text, passwordController.text, context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text("Iniciar sesión →", style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            // Implementar recuperación de contraseña
          },
          child: const Text("Olvidé mi contraseña. Recuperarla", style: TextStyle(color: Colors.orange)),
        ),
      ],
    );
  }

  /// 🔹 Formulario de Registro
  Widget _buildRegisterForm(AuthViewModel authViewModel) {
    return Column(
      key: const ValueKey(2),
      children: [
        TextField(controller: emailController, decoration: const InputDecoration(labelText: "Correo Electrónico")),
        TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Contraseña"), obscureText: true),
        TextField(controller: confirmPasswordController, decoration: const InputDecoration(labelText: "Confirmar Contraseña"), obscureText: true),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (passwordController.text == confirmPasswordController.text) {
              authViewModel.registerWithEmail(emailController.text, passwordController.text, context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Las contraseñas no coinciden")),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text("Crear →", style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ],
    );
  }
}
