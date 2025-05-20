import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item_model.dart';
import '../repositories/cart_repository.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'payment_mock_screen.dart';
import '../cache/mystery_box_cache.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartRepository _cartRepository = CartRepository();
  List<CartItem> _cartItems = [];
  bool _loading = true;
  bool _isMysteryBox = false;
  double? _sessionStartTime;
  bool _paymentCompleted = false;

  int _mysteryTotalQuantity = 0;
  double _mysteryTotalPrice = 0;

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
      final cachedBox = MysteryBoxCache().getCachedBox(uid);
      final mysteryIds = cachedBox?.map((p) => p.id).toSet() ?? {};

      bool allMatch = items.isNotEmpty &&
          mysteryIds.isNotEmpty &&
          items.every((item) => mysteryIds.contains(item.productId));

      if (allMatch) {
        final totalQty = items.fold<int>(0, (sum, item) => sum + item.quantity);
        final totalPrice = items.fold<double>(
            0, (sum, item) => sum + (item.price * item.quantity));

        setState(() {
          _isMysteryBox = true;
          _mysteryTotalQuantity = totalQty;
          _mysteryTotalPrice = totalPrice;
          _cartItems = items;
          _loading = false;
        });
      } else {
        setState(() {
          _isMysteryBox = false;
          _cartItems = items;
          _loading = false;
        });
      }
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
    if (_isMysteryBox) {
      final avg = _mysteryTotalPrice / _mysteryTotalQuantity;
      return avg * _mysteryTotalQuantity * 0.85;
    }
    return _cartItems.fold(
        0.0, (total, item) => total + item.price * item.quantity);
  }

  Future<void> _finalizePurchase() async {
    if (_paymentCompleted) return;
    _paymentCompleted = true;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _sessionStartTime == null) return;

    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    final sessionDuration = now - _sessionStartTime!;

    await _cartRepository.logCheckoutSession(
        uid, sessionDuration, _calculateTotal(), _cartItems);
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
      appBar: AppBar(title: const Text("Mi carrito"), centerTitle: true),
      bottomNavigationBar: CustomBottomNavBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? _buildEmptyView()
              : _isMysteryBox
                  ? _buildMysteryBoxView()
                  : _buildStandardCartView(),
    );
  }

  Widget _buildEmptyView() {
    return Center(
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Agregar algunos productos",
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildMysteryBoxView() {
    final avgPrice = _mysteryTotalPrice + _mysteryTotalQuantity;
    final discounted = avgPrice * 0.85;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Image.asset("assets/MysteryBox.png",
                          height: 80, width: 80, fit: BoxFit.cover),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Caja Misteriosa",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("$_mysteryTotalQuantity productos sorpresa",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Row(
                              children: [
                                Text("\$${discounted.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Text("\$${avgPrice.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey)),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        _buildFooter(),
      ],
    );
  }

  Widget _buildStandardCartView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(item.image,
                            width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("${item.discount.toInt()}% DCTO",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Row(
                              children: [
                                Text("\$${item.price.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.orange),
                                  onPressed: () => _updateQuantity(item, -1),
                                ),
                                Text(item.quantity.toString(),
                                    style: const TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: Colors.orange),
                                  onPressed: () => _updateQuantity(item, 1),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _updateQuantity(item, -item.quantity),
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
        _buildFooter(),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Pagar ahora",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("\$${_calculateTotal().toStringAsFixed(0)}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _handleMockPayment,
            icon: const Icon(Icons.payment, color: Colors.white),
            label: const Text("Pagar ahora →",
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
