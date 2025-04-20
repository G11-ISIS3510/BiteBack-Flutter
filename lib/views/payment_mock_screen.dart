import 'package:flutter/material.dart';

class PaymentMockScreen extends StatefulWidget {
  const PaymentMockScreen({super.key});

  @override
  State<PaymentMockScreen> createState() => _PaymentMockScreenState();
}

class _PaymentMockScreenState extends State<PaymentMockScreen> {
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _isProcessing = false);
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isProcessing
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 20),
                  Text("Procesando tu pago...", style: TextStyle(fontSize: 18)),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 80),
                  SizedBox(height: 20),
                  Text("¡Pago exitoso!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Serás redirigido al inicio", style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
      ),
    );
  }
}
