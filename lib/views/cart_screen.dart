import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../repositories/cart_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'payment_mock_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartRepository _cartRepository = CartRepository();
  List<CartItem> _cartItems = [];
  bool _loading = true;
  double? _sessionStartTime;
  bool _paymentCompleted = false;

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now().millisecondsSinceEpoch.toDouble();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final items = await _cartRepository.getCartItems(uid);
      setState(() {
        _cartItems = items;
        _loading = false;
      });
    }
  }

  Future<void> _updateQuantity(CartItem item, int delta) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final newQuantity = item.quantity + delta;

    if (newQuantity <= 0) {
      await _cartRepository.removeFromCart(uid, item.productId);
    } else {
      await _cartRepository.updateQuantity(uid, item.productId, newQuantity);
    }

    _fetchCart();
  }

  double _calculateTotal() {
    return _cartItems.fold(0.0, (total, item) => total + item.finalPrice * item.quantity);
  }

  Future<void> _finalizePurchase() async {

    if (_paymentCompleted) return;
    _paymentCompleted = true;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _sessionStartTime == null) return;

    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    final sessionDuration = now - _sessionStartTime!;

    await _cartRepository.logCheckoutSession(uid, sessionDuration, _calculateTotal(), _cartItems);
    await _cartRepository.clearCart(uid);
  }

  void _handleMockPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentMockScreen(onPaymentComplete: _finalizePurchase),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi carrito"),
        centerTitle: true,
      ),
      bottomNavigationBar: CustomBottomNavBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Tu carrito está vacío.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text("Agregar algunos productos",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    ),
  )

              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(item.image, width: 80, height: 80, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text("${item.discount.toInt()}% DCTO", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                        Row(
                                          children: [
                                            Text(
                                              "\$${item.finalPrice.toStringAsFixed(0)}",
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "\$${item.price.toStringAsFixed(0)}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                                              onPressed: () => _updateQuantity(item, -1),
                                            ),
                                            Text(item.quantity.toString(), style: const TextStyle(fontSize: 16)),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
                                              onPressed: () => _updateQuantity(item, 1),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _updateQuantity(item, -item.quantity),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Agregar más productos →", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Pagar ahora", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text("\$${_calculateTotal().toStringAsFixed(0)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _handleMockPayment,
                            icon: const Icon(Icons.payment, color: Colors.white),
                            label: const Text("Pagar ahora →", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
