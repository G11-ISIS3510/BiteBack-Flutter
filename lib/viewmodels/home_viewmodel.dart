import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user_location.dart';
import '../services/location_service.dart';

class HomeViewModel extends ChangeNotifier {

  // Variables de clase con valores iniciales
  String _userName = "Usuario";
  UserLocation? _location;
  String _address = "Ubicación no disponible";

  // Getters para exponer los valores
  String get userName => _userName;
  UserLocation? get location => _location;
  String get address => _address;

  // Carga los datos del usuario y su ubicación al instanciarse
  HomeViewModel() {
    _loadUserData();
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
}
