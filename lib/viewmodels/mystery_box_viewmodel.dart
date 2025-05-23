import 'dart:isolate';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/products_repository.dart';
import '../repositories/cart_repository.dart';
import '../models/product_model.dart';
import '../cache/mystery_box_cache.dart';

class MysteryBoxViewModel extends ChangeNotifier {
  final ProductsRepository _productsRepository = ProductsRepository();
  final CartRepository _cartRepository = CartRepository();

  int _selectedCount = 1;
  bool _loading = false;

  int get selectedCount => _selectedCount;
  bool get isLoading => _loading;

  void setSelectedCount(int count) {
    _selectedCount = count.clamp(1, 5);
    notifyListeners();
  }

  Future<void> generateMysteryBox() async {
    _loading = true;
    notifyListeners();

    final allProducts = await _productsRepository.getProducts();
    final selectedProducts = await _selectRandomProducts(_selectedCount, allProducts);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _cartRepository.clearCart(uid);
    await _cartRepository.addMysteryBoxProducts(uid, selectedProducts);

    
    LruMysteryBoxCache().cacheBox(uid, selectedProducts);

    _loading = false;
    notifyListeners();
  }

  static Future<List<Product>> _selectRandomProducts(int count, List<Product> products) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_isolateEntry, [receivePort.sendPort, products, count]);
    return await receivePort.first;
  }

  static void _isolateEntry(List<dynamic> args) {
    final SendPort sendPort = args[0];
    final List<Product> products = args[1];
    final int count = args[2];

    products.shuffle(Random());
    final selected = products.take(count).toList();
    Isolate.exit(sendPort, selected);
  }
}
