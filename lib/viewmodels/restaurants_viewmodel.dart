// ignore_for_file: prefer_final_fields

import 'package:biteback/repositories/rating_repository.dart';
import 'package:flutter/material.dart';
import '../models/business_model.dart';
import '../repositories/business_repository.dart';

class RestaurantsViewModel extends ChangeNotifier {

  // Inyección de repositorios para consultar a la base de datos
  final BusinessRepository _businessRepository = BusinessRepository();
  final RatingRepository _ratingRepository = RatingRepository();

  // Estructuras para almacenar los ratings calculados
  Map<String, double> _weeklyRatings = {};
  Map<String, double> get weeklyRatings => _weeklyRatings;

  // Estructura para almacenar los restaurantes
  List<Business> _restaurants = [];
  bool _isLoading = false;
  List<Business> get restaurants => _restaurants;
  bool get isLoading => _isLoading;

  RestaurantsViewModel() {
    loadRestaurantsAndRatings(); 
  }

  // Se cargan los restaurantes y ratings garantizando existencia de dependencias
  Future<void> loadRestaurantsAndRatings() async {
    _isLoading = true;
    notifyListeners();
    await loadRestaurants(); 
    await fetchWeeklyRatings(); 
    _isLoading = false;
    notifyListeners();
  }

  // Método para cargar los restaurantes
  Future<void> loadRestaurants() async {
    try {
      _restaurants = await _businessRepository.getRestaurants();
    } 
    catch (e) {
      _restaurants = [];
    }
  }

  // Método para calcular los ratings semanales
  Future<void> fetchWeeklyRatings() async {
    for (int i = 0; i < restaurants.length; i++) {
  final restaurant = restaurants[i];
  double rating = await _ratingRepository.getWeeklyRating(restaurant.name);
  _weeklyRatings[restaurant.name] = rating;
}

  }

  // Método que ordena por calificación general
  void sortByGeneralRating() {
    _restaurants.sort((a, b) => b.rating.compareTo(a.rating));
    notifyListeners();
  }

  // Método que ordena por calificación semanal
  void sortByWeeklyRating() {
    _restaurants.sort((a, b) {
      double ratingA = _weeklyRatings[a.name] ?? 0.0;
      double ratingB = _weeklyRatings[b.name] ?? 0.0;
      return ratingB.compareTo(ratingA);
    });
    notifyListeners();
  }
}
