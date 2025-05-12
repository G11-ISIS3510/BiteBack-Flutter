import '../models/product_model.dart';

class MysteryBoxCache {
  static final MysteryBoxCache _instance = MysteryBoxCache._internal();
  factory MysteryBoxCache() => _instance;
  MysteryBoxCache._internal();

  final Map<String, List<Product>> _cache = {};

  void cacheBox(String userId, List<Product> products) {
    _cache[userId] = List<Product>.from(products);
  }

  List<Product>? getCachedBox(String userId) {
    return _cache[userId];
  }

  void clearCache(String userId) {
    _cache.remove(userId);
  }

  bool hasCache(String userId) {
    return _cache.containsKey(userId);
  }
}
