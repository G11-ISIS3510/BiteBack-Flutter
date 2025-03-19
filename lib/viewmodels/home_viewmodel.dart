import 'package:biteback/models/product_model.dart';
import 'package:biteback/repositories/analytics_repository.dart';
import 'package:biteback/repositories/business_repository.dart';
import 'package:biteback/repositories/products_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/business_model.dart';
import '../models/user_location_model.dart';
import '../services/location_service.dart';

class HomeViewModel extends ChangeNotifier {

  // Inyección de repositorios para manejo de la base de datos
  final BusinessRepository _businessRepository = BusinessRepository();
  final ProductsRepository _productsRepository = ProductsRepository();
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();

  // Variables de clase y de estado
  String _userName = "Usuario";
  UserLocation? _location;
  String _address = "Ubicación no disponible";
  List<Business> _allRestaurants = [];
  List<Product> _allProducts = [];
  List<Product> _nearbyProducts = [];
  List<Product> _filteredProducts = [];
  Set<String> _categories = {};
  String _selectedCategory = "";
  String _searchQuery = "";

  // Getters para obtener los atributos
  String get userName => _userName;
  UserLocation? get location => _location;
  String get address => _address;
  List<Business> get allRestaurants => _allRestaurants;
  Set<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  List<Product> get allProducts => _allProducts;
  List<Product> get nearbyProducts => _nearbyProducts;
  List<Product> get filteredProducts => _filteredProducts; 
  String get searchQuery => _searchQuery; 

  // Carga de los datos del usuario y categorias
  HomeViewModel() {
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    final Stopwatch stopwatch = Stopwatch()..start(); 

    await _loadUserData();
    await _loadCategories();

    stopwatch.stop(); 
    double loadTime = stopwatch.elapsedMilliseconds / 1000.0; 
    await _analyticsRepository.addLoadTimeHomePage(loadTime); 
  }


  // Método que carga el nombre y ubicación del usuario
  // Támbien carga los restaurantes, productos y los asocia
  Future<void> _loadUserData() async {

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userName = user.displayName ?? user.email ?? "Usuario";
    }

    // 
    Position? position = await LocationService.getCurrentPosition();
    if (position != null) {
      _location = UserLocation(latitude: position.latitude, longitude: position.longitude);
      _address = await LocationService.getAddressFromCoordinates(position);
    } else {
      _address = "No se pudo obtener la ubicación.";
    }

    notifyListeners();

    // Espera a la carga de los recursos
    await Future.wait([
      _loadRestaurants(),
      _loadProducts(),
    ]);

    // Linkea y carga productos cercanos
    _linkProductsToRestaurants();
    _loadNearbyProducts();
  }

  // Método para cargar los restaurantes
  Future<void> _loadRestaurants() async {
    _allRestaurants = await _businessRepository.getRestaurants();
    notifyListeners();
  }

  // Método para cargar los productos
  Future<void> _loadProducts() async {
    _allProducts = await _productsRepository.getProducts();
    _filteredProducts = _allProducts;
    notifyListeners();
  }

  // Método para asociar productos con restaurantes
  void _linkProductsToRestaurants() {
    for (var restaurant in _allRestaurants) {
      restaurant.products = _allProducts.where((product) => product.businessId == restaurant.id).toList();
    }
    notifyListeners();
  }

  // Método para cargar los productos cercanos
  void _loadNearbyProducts() {
    if (_location == null) return;

    const double maxDistance = 5000; 
    List<Product> nearbyProducts = [];

    for (var restaurant in _allRestaurants) {
      double distance = Geolocator.distanceBetween(
        _location!.latitude, 
        _location!.longitude, 
        restaurant.latitude, 
        restaurant.longitude
      );

      if (distance <= maxDistance) {
        nearbyProducts.addAll(restaurant.products);
      }
    }

    _nearbyProducts = nearbyProducts;
    notifyListeners();
  }

  // Método para cargar las categorias
  Future<void> _loadCategories() async {
    _categories = await _productsRepository.getUniqueCategories();
    notifyListeners();
  }

  // Método para manejar la selección de categorias
  void setSelectedCategory(String category) {
    if (_selectedCategory == category) {
      _selectedCategory = ""; 
    } else {
      _selectedCategory = category;
    }
    filterProducts(_searchQuery); 
  }

  // Método para hacer el filtrado de productos
  void filterProducts(String query) {

    _searchQuery = query; 

    _filteredProducts = _allProducts.where((product) {
      bool matchesQuery = query.isEmpty || product.name.toLowerCase().contains(query.toLowerCase());
      bool matchesCategory = _selectedCategory.isEmpty || product.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    notifyListeners(); 
  }
}


