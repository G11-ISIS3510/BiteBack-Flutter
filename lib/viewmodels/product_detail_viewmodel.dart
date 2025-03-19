import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/product_model.dart';
import '../models/business_model.dart';
import '../repositories/business_repository.dart';

class ProductDetailViewModel extends ChangeNotifier {
  final BusinessRepository _businessRepository = BusinessRepository();

  String _businessName = "Cargando...";
  String _businessDistance = "Cargando...";

  String get businessName => _businessName;
  String get businessDistance => _businessDistance;

  // Fetch Business Details (Name + Distance)
  Future<void> fetchBusinessDetails(Product product, Position userLocation) async {
    await _fetchBusinessName(product.businessId);
    await _fetchBusinessDistance(product.businessId, userLocation);
  }

  // Fetch Business Name
  Future<void> _fetchBusinessName(String businessId) async {
    Business? business = await _businessRepository.getBusinessById(businessId);
    _businessName = business?.name ?? "No disponible";
    notifyListeners();
  }

  // Fetch Business Distance
  Future<void> _fetchBusinessDistance(String businessId, Position userLocation) async {
    Business? business = await _businessRepository.getBusinessById(businessId);
    if (business != null) {
      double distance = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        business.latitude,
        business.longitude,
      ) / 1000; // Convert meters to km

      _businessDistance = "${distance.toStringAsFixed(1)} km";
    } else {
      _businessDistance = "No disponible";
    }

    notifyListeners();
  }
}
