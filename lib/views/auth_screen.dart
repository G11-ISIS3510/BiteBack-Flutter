// ignore_for_file: use_super_parameters, library_private_types_in_public_api

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

  String? emailError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;

  @override
  void initState() {
    super.initState();
    isRegisterMode = widget.isRegister;
  }

    bool _validateEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  bool _validatePhone(String phone) {
    final phoneRegex = RegExp(r"^[0-9]{10,}$");
    return phoneRegex.hasMatch(phone);
  }

@override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                const SizedBox(height: 50),
              ],
            ),
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
        _buildDivider(),
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
      height: 280,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isRegisterMode ? _buildRegisterForm(authViewModel) : _buildLoginForm(authViewModel),
      ),
    );
  }

  Widget _buildLoginForm(AuthViewModel authViewModel) {
  return Column(
    children: [
      if (isEmailMode) ...[
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: "Correo Electrónico",
            errorText: emailError, 
          ),
        ),
      ] else ...[
        TextField(
          controller: phoneController,
          decoration: InputDecoration(
            labelText: "Número de Teléfono",
            errorText: phoneError, 
          ),
          keyboardType: TextInputType.number,
        ),
      ],
      TextField(
        controller: passwordController,
        decoration: InputDecoration(
          labelText: "Contraseña",
          errorText: passwordError, 
        ),
        obscureText: true,
      ),
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
      children: [
        if (isEmailMode) ...[
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: "Correo Electrónico",
              errorText: emailError,
            ),
          ),
        ] else ...[
          TextField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: "Número de Teléfono",
              errorText: phoneError,
            ),
            keyboardType: TextInputType.number,
          ),
        ],
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: "Contraseña",
            errorText: passwordError,
          ),
          obscureText: true,
        ),
        TextField(
          controller: confirmPasswordController,
          decoration: InputDecoration(
            labelText: "Confirmar Contraseña",
            errorText: confirmPasswordError,
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
  onPressed: () {
    setState(() {
      emailError = null;
      phoneError = null;
      passwordError = null;
      confirmPasswordError = null;
    });

    bool isValid = true;

    if (isEmailMode) {
      if (!_validateEmail(emailController.text)) {
        setState(() {
          emailError = "Formato de correo inválido";
        });
        isValid = false;
      }
    } else {
      if (!_validatePhone(phoneController.text)) {
        setState(() {
          phoneError = "Número de teléfono inválido (mínimo 10 dígitos)";
        });
        isValid = false;
      }
    }

    if (passwordController.text.length < 8) {
      setState(() {
        passwordError = "Debe tener al menos 8 caracteres";
      });
      isValid = false;
    }

    if (isRegisterMode) {
      if (passwordController.text != confirmPasswordController.text) {
        setState(() {
          confirmPasswordError = "Las contraseñas no coinciden";
        });
        isValid = false;
      }
    }

    if (isValid) {
      if (isEmailMode) {
        authViewModel.registerWithEmail(emailController.text, passwordController.text, context);
      } else {
        authViewModel.registerWithPhone(phoneController.text, context);
      }
    }
  },
  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
  child: const Text("Registrarse →", style: TextStyle(color: Colors.white, fontSize: 18)),
),

      ],
    );
  }
}