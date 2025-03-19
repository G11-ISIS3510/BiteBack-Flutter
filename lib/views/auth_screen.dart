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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildAuthSwitcher(),
              const SizedBox(height: 20),
              _buildSocialButtons(authViewModel),
              const SizedBox(height: 10),
              _buildFormContainer(authViewModel), 
            ],
          ),
        ),
      ),
    );
  }

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
Widget _buildSocialButtons(AuthViewModel authViewModel) {
  return Column(
    children: [
      Row(
        children: const [
          Text("Consigue tus mejores ofertas", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
        ],
      ),
      const SizedBox(height: 10), 
      Row(
        children: const [
          Text("Registrarse con:", style: TextStyle(fontSize: 15)), 
        ],
      ),
      const SizedBox(height: 15),
      Row(
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
                  const Text("Sign in with Google"),
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
                  Text(isEmailMode ? "Correo electrónico" : "Número de Teléfono"),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _buildDivider(), // ✅ Añadimos la línea divisoria
    ],
  );
}

Widget _buildDivider() {
  return Row(
    children: const [
      Expanded(child: Divider(thickness: 1, color: Colors.grey)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text("o", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
      Expanded(child: Divider(thickness: 1, color: Colors.grey)),
    ],
  );
}

  Widget _buildFormContainer(AuthViewModel authViewModel) {
    return SizedBox(
      height: 280, // ✅ Altura fija para evitar movimientos
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isRegisterMode ? _buildRegisterForm(authViewModel) : _buildLoginForm(authViewModel),
      ),
    );
  }

  Widget _buildLoginForm(AuthViewModel authViewModel) {
    return Column(
      key: const ValueKey(1),
      children: [
        isEmailMode
            ? TextField(controller: emailController, decoration: const InputDecoration(labelText: "Correo Electrónico"))
            : TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Número de Teléfono")),

        TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Contraseña"), obscureText: true),

        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (isEmailMode) {
              authViewModel.loginWithEmail(emailController.text, passwordController.text, context);
            } else {
              authViewModel.registerWithPhone(phoneController.text, context);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text("Continuar →", style: TextStyle(color: Colors.white, fontSize: 18)),
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

  Widget _buildRegisterForm(AuthViewModel authViewModel) {
    return Column(
      key: const ValueKey(2),
      children: [
        isEmailMode
            ? TextField(controller: emailController, decoration: const InputDecoration(labelText: "Correo Electrónico"))
            : TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Número de Teléfono")),

        TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Contraseña"), obscureText: true),
        TextField(controller: confirmPasswordController, decoration: const InputDecoration(labelText: "Confirmar Contraseña"), obscureText: true),

        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (passwordController.text == confirmPasswordController.text) {
              if (isEmailMode) {
                authViewModel.registerWithEmail(emailController.text, passwordController.text, context);
              } else {
                authViewModel.registerWithPhone(phoneController.text, context);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Las contraseñas no coinciden")),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text("Registrarse →", style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ],
    );
  }
}
