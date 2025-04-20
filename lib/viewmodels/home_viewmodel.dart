import 'package:biteback/models/product_model.dart';
import 'package:biteback/repositories/analytics_repository.dart';
import 'package:biteback/repositories/business_repository.dart';
import 'package:biteback/repositories/products_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_model.dart';
import '../models/user_location_model.dart';
import '../services/location_service.dart';
import 'dart:convert';

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
  List<Product> _recentSearchResults = [];
  Set<String> _categories = {};
  String _selectedCategory = "";
  String _searchQuery = "";
  final Map<String, String> _businessNames = {};
  bool _isOffline = false;



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
  List<Product> get recentSearchResults => _recentSearchResults;
  String get searchQuery => _searchQuery;
  Map<String, String> get businessNames => _businessNames;
  bool get isOffline => _isOffline;

  // Carga de los datos del usuario y categorias
  HomeViewModel() {
    _loadHomeData();
  }

  // Metodo para verificar si se cuenta con conexion en el dispositivo
  Future<bool> hasConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  Future<void> _loadHomeData() async {
    final Stopwatch stopwatch = Stopwatch()..start(); 
    _isOffline = !(await hasConnection());

    await _loadUserData();
    await _loadCategories();
    await _loadLastSearchResults();

    stopwatch.stop(); 
    double loadTime = stopwatch.elapsedMilliseconds / 1000.0; 
    if (!_isOffline) await _analyticsRepository.addLoadTimeHomePage(loadTime); 
  }


  // Método que carga el nombre y ubicación del usuario
  // Támbien carga los restaurantes, productos y los asocia
  Future<void> _loadUserData() async {

  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    _userName = user.displayName ?? user.email ?? "Usuario";
  }

  // Verificar si hay conexión a Internet
  _isOffline = !(await hasConnection());

  if (_isOffline) {
    _address = "Ubicación no disponible debido a la falta de conexión a internet.";
  } else {
    // Obtener la ubicación solo si hay conexión
    try {
      Position? position = await LocationService.getCurrentPosition();
      if (position != null) {
        _location = UserLocation(latitude: position.latitude, longitude: position.longitude);
        _address = await LocationService.getAddressFromCoordinates(position);
      } else {
        _address = "No se pudo obtener la ubicación.";
      }
    } catch (e) {
      _address = "No se pudo obtener la ubicación: $e";
    }
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

  if (!_isOffline) {
    await _cacheRestaurants();
    await _cacheProducts();
  }
}

  // Método para cargar los restaurantes
  Future<void> _loadRestaurants() async {
    try {
      if (_isOffline) {
        _allRestaurants = await _loadCachedRestaurants();
      } else {
        _allRestaurants = await _businessRepository.getRestaurants();
        await _cacheRestaurants();
      }
    } catch (_) {
      _allRestaurants = await _loadCachedRestaurants();
    }
    notifyListeners();
  }

  // Método para cargar los productos
  Future<void> _loadProducts() async {
    try {
      if (_isOffline) {
        _allProducts = await _loadCachedProducts();
      } else {
        _allProducts = await _productsRepository.getProducts();
        await _cacheProducts();
      }
      _filteredProducts = _allProducts;
    } catch (_) {
      _allProducts = await _loadCachedProducts();
    }
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
    try {
      if (_isOffline) {
        _categories = await _loadCachedCategories();
      } else {
        _categories = await _productsRepository.getUniqueCategories();
        await _cacheCategories();
      }
    } catch (_) {
      _categories = await _loadCachedCategories();
    }
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
    // Actualizando la analítica
    if (!_isOffline) _analyticsRepository.addSearch(query);
    _searchQuery = query; 

    _filteredProducts = _allProducts.where((product) {
      bool matchesQuery = query.isEmpty || product.name.toLowerCase().contains(query.toLowerCase());
      bool matchesCategory = _selectedCategory.isEmpty || product.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    if (_filteredProducts.isNotEmpty) {
      for (final product in filteredProducts) {
        addRecentSearch(product);
      }
    }
    notifyListeners(); 
  }

  // Método para resetear la lista de productos filtrados
  void resetProducts() {
    _filteredProducts = List.from(_allProducts);
    notifyListeners();
  }

  // Metodo para añadir un busqueda a la lista de busquedas recientes
  Future<void> addRecentSearch(Product product) async {
    // Condicon para evitar que aparezcan busquedas duplicadas
    _recentSearchResults.removeWhere((r) => r.id == product.id); 
    // Se agrega la nueva busqueda al inicio
    _recentSearchResults.insert(0, product);
    // Se mantienen unicamente las diez busquedas mas recientes 
    if (_recentSearchResults.length > 10) {
      _recentSearchResults = _recentSearchResults.sublist(0, 10); // máximo 10
    }
    await _saveLastSearchResults(); 
    notifyListeners();
  }

  // Metodo para guardar las ultimas busquedas realizadas por el usuario
  Future<void> _saveLastSearchResults() async {
    // Se obtiene la instancia de las preferencias locales usada para almacenar la informacion
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> idList = _recentSearchResults.map((product) {
      return product.id.toString();
    }).toList();
    await prefs.setStringList('lastSearchResults', idList);
  }

  // Metodo que se encarga de cargar los resultados de las ultimas busquedas
  Future<void> _loadLastSearchResults() async {
    // Se obtiene la instancia de las preferencias locales usada para almacenar la informacion
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? idList = prefs.getStringList('lastSearchResults');

    // Si existen busquedas recientes, se obtiene sus resultados
    if (idList != null) {
      _recentSearchResults = idList.map((id) {
        try {
          return _allProducts.firstWhere((r) => r.id == id);
        } 
        catch (_) {
          return null; 
        }
      }).whereType<Product>().toList();
    } 
    else {
      _recentSearchResults = [];
    }
    notifyListeners();
  }

  // Método que se encarga de limpiar las búsquedas recientes
  Future<void> clearRecentSearches() async {
    // Limpiar la lista en memoria
    recentSearchResults.clear();
    // Limpiar las búsquedas recientes en SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('lastSearchResults'); 

    // Notificar a los listeners para actualizar la UI
    notifyListeners();
  }

  Future<void> _cacheRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _allRestaurants.map((r) => r.toJson()).toList();
    await prefs.setString('cachedRestaurants', jsonEncode(jsonList));
  }

  Future<List<Business>> _loadCachedRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('cachedRestaurants');
    if (jsonStr != null) {
      final List list = jsonDecode(jsonStr);
      return list.map((e) => Business.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> _cacheProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _allProducts.map((p) => p.toJson()).toList();
    await prefs.setString('cachedProducts', jsonEncode(jsonList));
  }

  Future<List<Product>> _loadCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('cachedProducts');
    if (jsonStr != null) {
      final List list = jsonDecode(jsonStr);
      return list.map((e) => Product.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> _cacheCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cachedCategories', _categories.toList());
  }

  Future<Set<String>> _loadCachedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('cachedCategories');
    return list?.toSet() ?? {};
  }
}


