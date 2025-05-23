import 'dart:collection';
import '../models/product_model.dart';

class LruMysteryBoxCache {
  static final LruMysteryBoxCache _instance = LruMysteryBoxCache._internal();
  factory LruMysteryBoxCache() => _instance;
  LruMysteryBoxCache._internal();

  final int _maxSize = 100; 
  final LinkedHashMap<String, List<Product>> _cache = LinkedHashMap();

  void cacheBox(String userId, List<Product> products) {
    if (_cache.containsKey(userId)) {
      _cache.remove(userId);
    } else if (_cache.length >= _maxSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[userId] = List<Product>.from(products);
  }

  List<Product>? getCachedBox(String userId) {
    if (!_cache.containsKey(userId)) return null;
    final products = _cache.remove(userId)!;
    _cache[userId] = products;
    return products;
  }

  void clearCache(String userId) {
    _cache.remove(userId);
  }

  bool hasCache(String userId) {
    return _cache.containsKey(userId);
  }
}
