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
  Set<String> _categories = {};


  // Getters para exponer los valores
  String get userName => _userName;
  UserLocation? get location => _location;
  String get address => _address;
  List<Business> get allRestaurants => _allRestaurants;
  List<Business> get filteredRestaurants => _filteredrestaurants;
  Set<String> get categories => _categories;

  // Carga los datos del usuario y su ubicación al instanciarse
  // Carga los restaurantes al instanciarse
  HomeViewModel() {
    _loadUserData();
    _loadRestaurants();
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
  }

  // Método para obtener todos los negocios de tipo restaurante
  Future<void> _loadRestaurants() async {
    _allRestaurants = await _businessRepository.getRestaurants();
    _filteredrestaurants = _allRestaurants;
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
}
