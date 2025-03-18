import 'package:biteback/models/product_model.dart';
import 'package:biteback/repositories/business_repository.dart';
import 'package:biteback/repositories/products_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/business_model.dart';
import '../models/user_location_model.dart';
import '../services/location_service.dart';

class HomeViewModel extends ChangeNotifier {

  // Dependencias a repositorios
  final BusinessRepository _businessRepository = BusinessRepository();
  final ProductsRepository _productsRepository = ProductsRepository();

  // Variables de clase con valores iniciales
  String _userName = "Usuario";
  UserLocation? _location;
  String _address = "Ubicación no disponible";
  List<Business> _allRestaurants = [];
  List<Business> _filteredrestaurants = [];
  List<Product> _allProducts = [];
  List<Product> _nearbyProducts = [];
  Set<String> _categories = {};
  String _selectedCategory = "";


  // Getters para exponer los valores
  String get userName => _userName;
  UserLocation? get location => _location;
  String get address => _address;
  List<Business> get allRestaurants => _allRestaurants;
  List<Business> get filteredRestaurants => _filteredrestaurants;
  Set<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  List<Product> get allProducts => _allProducts;
  List<Product> get nearbyProducts => _nearbyProducts;

  // Carga los datos del usuario y su ubicación al instanciarse
  // Tambien se cargan las categorias
  HomeViewModel() {
    _loadUserData();
    _loadCategories();
  }

  // Método para obtener el nombre y ubicación del usuario autenticado
  Future<void> _loadUserData() async {
    // Obtener usuario autenticado
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userName = user.displayName ?? user.email ?? "Usuario";
    }

    // Obtener la ubicación usando LocationService
    Position? position = await LocationService.getCurrentPosition();
    if (position != null) {
      _location = UserLocation(latitude: position.latitude, longitude: position.longitude);
      _address = await LocationService.getAddressFromCoordinates(position);
    } 
    else {
      _address = "No se pudo obtener la ubicación.";
    }

    // Notificar cambios a la vista
    notifyListeners();

    // Carga de los restaurantes y productos
    await Future.wait([
      _loadRestaurants(),
      _loadProducts(),
    ]);

    // Vincular productos a restaurantes
    _linkProductsToRestaurants();

    // Carga de productos más cercanos
    _loadNearbyProducts();
  }

  // Método para obtener todos los negocios de tipo restaurante
  Future<void> _loadRestaurants() async {
    _allRestaurants = await _businessRepository.getRestaurants();
    _filteredrestaurants = _allRestaurants;
    notifyListeners(); 
  }

  // Método para obtener todos los productos ofertados
  Future<void> _loadProducts() async {
    _allProducts = await _productsRepository.getProducts();
    notifyListeners();
  }

  // Método para linkear cada producto a su restaurante correspondeinte
  void _linkProductsToRestaurants() {
    for (var restaurant in _allRestaurants) {
      restaurant.products = _allProducts.where((product) => product.businessId == restaurant.id).toList();
    }
    notifyListeners();
  }

  // Método para cargar los restaurantes más cercanos a la ubicación del usuario
  void _loadNearbyProducts() {
    if (_location == null) return;

    // Distancia máxima de 5 km
    const double maxDistance = 5000; 
    List<Product> nearbyProducts = [];

    // Se revisa que restaurantes cumplen con la cota de distancia
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

  // Método para filtrar restaurantes por un nombre
  void filterRestaurants(String query) {
    if (query.isEmpty) {
      _filteredrestaurants = allRestaurants;
    } 
    // Se ejecuta la consulta en caso de que exista
    else {
      _filteredrestaurants = allRestaurants.where((restaurant) {
        return restaurant.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  // Método para obtener las categorias unicas de comida
  Future<void> _loadCategories() async {
    _categories = await _productsRepository.getUniqueCategories();
    notifyListeners(); 
  }

  // Método para actualizar la categoría seleccionada en la vista
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
