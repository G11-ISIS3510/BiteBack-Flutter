import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> logCartSessionStart(String uid) async {
    final cartSessionId = DateTime.now().millisecondsSinceEpoch.toString();

    await _firestore
        .collection('cart_sessions')
        .doc(uid)
        .collection('entries')
        .doc(cartSessionId)
        .set({
      'entered_at': Timestamp.now(),
      'status': 'in_progress',
    });

    return cartSessionId;
  }

  Future<void> clearCart(String uid) async {
  final cartRef = _firestore.collection("users").doc(uid).collection("cart");
  final snapshot = await cartRef.get();

  for (final doc in snapshot.docs) {
    await doc.reference.delete();
  }
}

Future<void> logCheckoutSession(String uid, double durationMs, double total, List<CartItem> items) async {
  final checkoutId = DateTime.now().millisecondsSinceEpoch.toString();

  await _firestore
      .collection('checkout_sessions')
      .doc(uid)
      .collection('entries')
      .doc(checkoutId)
      .set({
    'duration_ms': durationMs,
    'completed_at': Timestamp.now(),
    'total': total,
    'item_count': items.length,
    'items': items.map((item) => {
      'product_id': item.productId,
      'name': item.name,
      'quantity': item.quantity,
      'price': item.price,
      'discount': item.discount,
      'final_price': item.finalPrice,
    }).toList(),
  });
}


Future<String> getOrCreateCartSession(String uid) async {
  final entries = await _firestore
      .collection('cart_sessions')
      .doc(uid)
      .collection('entries')
      .orderBy('entered_at', descending: true)
      .limit(1)
      .get();

  if (entries.docs.isNotEmpty && entries.docs.first['status'] == 'in_progress') {
    return entries.docs.first.id;
  } else {
    return await logCartSessionStart(uid);
  }
}



  Future<void> updateCartSession(String uid, String sessionId, double total, List<CartItem> items) async {
    await _firestore
        .collection('cart_sessions')
        .doc(uid)
        .collection('entries')
        .doc(sessionId)
        .update({
      'total': total,
      'item_count': items.length,
      'items': items.map((item) => {
        'product_id': item.productId,
        'name': item.name,
        'quantity': item.quantity,
        'price': item.price,
        'discount': item.discount,
        'final_price': item.finalPrice,
      }).toList(),
    });
  }

  Future<void> completeCartSession(String uid, String sessionId) async {
    await _firestore
        .collection('cart_sessions')
        .doc(uid)
        .collection('entries')
        .doc(sessionId)
        .update({
      'completed_at': Timestamp.now(),
      'status': 'completed',
    });
  }

  Future<void> addToCart(String uid, Product product) async {
  final cartItem = CartItem(
    productId: product.id,
    name: product.name,
    price: product.price,
    discount: product.discount,
    image: product.image,
  );

  await _firestore
    .collection("users")
    .doc(uid)
    .collection("cart")
    .doc(product.id)
    .set(cartItem.toMap(), SetOptions(merge: true));
}


  Future<List<CartItem>> getCartItems(String uid) async {
    final snapshot = await _firestore
        .collection("users")
        .doc(uid)
        .collection("cart")
        .get();

    return snapshot.docs.map((doc) => CartItem.fromMap(doc.data())).toList();
  }

  Future<void> removeFromCart(String uid, String productId) async {
    await _firestore
        .collection("users")
        .doc(uid)
        .collection("cart")
        .doc(productId)
        .delete();
  }

  Future<void> updateQuantity(String uid, String productId, int quantity) async {
    await _firestore
        .collection("users")
        .doc(uid)
        .collection("cart")
        .doc(productId)
        .update({'quantity': quantity});
  }
}
