import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../repositories/cart_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_bottom_navbar.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartRepository _cartRepository = CartRepository();
  List<CartItem> _cartItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
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
    return _cartItems.fold(0.0, (total, item) => total + item.price * item.quantity);
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
              ? const Center(child: Text("Tu carrito está vacío."))
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
                                        Text("${item.price.toStringAsFixed(0)}", style: const TextStyle(color: Colors.orange)),
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
                          onPressed: () {
                            Navigator.pushNamed(context, '/payment');
                          },
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