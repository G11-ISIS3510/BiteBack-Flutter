import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
