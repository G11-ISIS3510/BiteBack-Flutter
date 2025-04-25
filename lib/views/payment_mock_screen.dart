import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class PaymentMockScreen extends StatefulWidget {
  final Future<void> Function() onPaymentComplete;

  const PaymentMockScreen({super.key, required this.onPaymentComplete});

  @override
  State<PaymentMockScreen> createState() => _PaymentMockScreenState();
}

class _PaymentMockScreenState extends State<PaymentMockScreen> {
  bool _isProcessing = true;
  bool _isOffline = false;
  bool _paymentCompleted = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _startConnectivityMonitoring();
    _simulatePayment();
  }

  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection && _isOffline) {
        _retryPayment();
      }
    });
  }

  Future<void> _simulatePayment() async {

    final results = await Connectivity().checkConnectivity();
    final hasConnection = results.any((r) => r != ConnectivityResult.none);

    if (!hasConnection) {
      setState(() {
        _isOffline = true;
        _isProcessing = false;
      });
    } else {
      if (_paymentCompleted) return;
      _paymentCompleted = true;
      await widget.onPaymentComplete();
      _showSuccessAndNavigate();
    }

  }

  Future<void> _retryPayment() async {
    setState(() {
      _isProcessing = true;
      _isOffline = false;
    });

    if (_paymentCompleted) return;
    _paymentCompleted = true;
    await widget.onPaymentComplete();
    _showSuccessAndNavigate();
  }

  void _showSuccessAndNavigate() async {
    setState(() => _isProcessing=false);
    
    await Future.delayed(const Duration(seconds: 2));
    if(mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Procesando Pago')),
      body: Center(
        child: _isOffline
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.wifi_off, color: Colors.red, size: 64),
                  SizedBox(height: 20),
                  Text(
                    'Sin conexión. El pago se completará automáticamente cuando se restablezca la conexión.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              )
            :_isProcessing
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
