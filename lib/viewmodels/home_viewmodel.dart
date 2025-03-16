import 'package:biteback/repositories/business_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/business_model.dart';
import '../models/user_location_model.dart';
import '../services/location_service.dart';

class HomeViewModel extends ChangeNotifier {

  // Dependencias a repositorios
  final BusinessRepository _businessRepository = BusinessRepository();

  // Variables de clase con valores iniciales
  String _userName = "Usuario";
  UserLocation? _location;
  String _address = "Ubicación no disponible";
  List<Business> _restaurants = [];

  // Getters para exponer los valores
  String get userName => _userName;
  UserLocation? get location => _location;
  String get address => _address;
  List<Business> get restaurants => _restaurants;

  // Carga los datos del usuario y su ubicación al instanciarse
  // Carga los restaurantes al instanciarse
  HomeViewModel() {
    _loadUserData();
    _loadRestaurants();
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
    _restaurants = await _businessRepository.getRestaurants();
    print(_restaurants.length);
    for (var restaurant in _restaurants) {
      print("ID: ${restaurant.id}");
      print("Nombre: ${restaurant.name}");
      print("Tipo: ${restaurant.type}");
      print("Latitud: ${restaurant.latitude}");
      print("Longitud: ${restaurant.longitude}");
      print("Rating: ${restaurant.rating}");
      print("Imagen: ${restaurant.image}");
      print("Horario: ${restaurant.openHour} - ${restaurant.closeHour}");
      print("-----------------------------");
    }
    notifyListeners(); 
  }
}
