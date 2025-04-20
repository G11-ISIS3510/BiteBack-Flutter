import 'package:flutter/material.dart';

class PaymentMockScreen extends StatefulWidget {
  final Future<void> Function() onPaymentComplete;

  const PaymentMockScreen({super.key, required this.onPaymentComplete});

  @override
  State<PaymentMockScreen> createState() => _PaymentMockScreenState();
}

class _PaymentMockScreenState extends State<PaymentMockScreen> {
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _simulatePayment();
  }

  Future<void> _simulatePayment() async {
    await Future.delayed(const Duration(seconds: 2));

    await widget.onPaymentComplete();

    setState(() => _isProcessing = false);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Procesando Pago')),
      body: Center(
        child: _isProcessing
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Procesando tu pago...', style: TextStyle(fontSize: 16)),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 64),
                  SizedBox(height: 20),
                  Text('¡Pago exitoso!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }
}
