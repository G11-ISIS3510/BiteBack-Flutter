import 'package:biteback/repositories/analytics_repository.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/product_model.dart';
import '../models/business_model.dart';
import '../repositories/business_repository.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:biteback/repositories/cart_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailViewModel extends ChangeNotifier {
  // Dependencias para el manejo de datos
  final BusinessRepository _businessRepository = BusinessRepository();
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();
  final CartRepository _cartRepository = CartRepository();

  String _businessName = "Cargando...";
  String _businessDistance = "Cargando...";
  Position? _userLocation; // Guarda la ubicación del usuario

  String get businessName => _businessName;
  String get businessDistance => _businessDistance;

  bool _productAdded = false;
  bool get productAdded => _productAdded;

  bool _offlineQueuedMessageShown = false;
  bool get offlineQueuedMessageShown => _offlineQueuedMessageShown;

  bool _hasConnection = true;
  bool get hasConnection => _hasConnection;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  Product? _lastFetchedProduct;
  Product? _queuedCartProduct;

  // Inicialización del ViewModel (llamar en initState)
  Future<void> init(Product product) async {
    _lastFetchedProduct = product;
    _monitorConnectivity();

    await _getUserLocation();
    if (_userLocation != null) {
      await fetchBusinessDetails(product);
    }
  }

  // Obtiene la ubicación del usuario solo una vez
  Future<void> _getUserLocation() async {
    try {
      _userLocation = await Geolocator.getCurrentPosition();
    } catch (e) {
      _businessDistance = "Ubicación no disponible";
    }
  }

  // Obtiene los detalles del negocio (nombre + distancia)
  Future<void> fetchBusinessDetails(Product product) async {
    await _fetchBusinessName(product.businessId);
    if (_userLocation != null) {
      await _fetchBusinessDistance(product.businessId);
    }
    // Registrar interacción en analítica
    _analyticsRepository.addClickInteractionProduct(product.category, product.name);
  }

  // Obtiene el nombre del negocio
  Future<void> _fetchBusinessName(String businessId) async {
    Business? business = await _businessRepository.getBusinessById(businessId);
    _businessName = business?.name ?? "No disponible";
    notifyListeners();
  }

  // Calcula la distancia del usuario al negocio
  Future<void> _fetchBusinessDistance(String businessId) async {
    Business? business = await _businessRepository.getBusinessById(businessId);
    if (business != null && _userLocation != null) {
      double distance = Geolocator.distanceBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        business.latitude,
        business.longitude,
      ) / 1000; // Convertir metros a km

      _businessDistance = "${distance.toStringAsFixed(1)} km";
    } else {
      _businessDistance = "No disponible";
    }
    notifyListeners();
  }

  Future <void> addToCart(Product product) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if(uid == null) return;

    if (!_hasConnection){
      _queuedCartProduct = product;
      _offlineQueuedMessageShown = true;
      await _saveQueuedProduct(product);
      notifyListeners();
      return;
    }

    await _cartRepository.addToCart(uid, product);
    _productAdded = true;
    notifyListeners();

  }

  Future<void> _saveQueuedProduct(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final productJson = jsonEncode(product.toJson());
    await prefs.setString('queued_product', productJson);
  }

  Future<void> _processQueuedProduct() async {
    final prefs = await SharedPreferences.getInstance();
    final productJson = prefs.getString('queued_product');

    if (productJson != null) {
      final productMap = jsonDecode(productJson);
      final product = Product.fromJson(productMap);
      await addToCart(product);
      await prefs.remove('queued_product');
    }
  }

  void resetProductAdded() {
    _productAdded = false;
  }
  
  void resetOfflineMessageFlag() {
    _offlineQueuedMessageShown = false;
  }


  void _monitorConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) async {
      final connected = results.any((r) => r != ConnectivityResult.none);

      if(_hasConnection != connected){
        _hasConnection = connected;
        notifyListeners();
        
        if (connected) {

          if (_userLocation != null && _lastFetchedProduct != null) {
            await fetchBusinessDetails(_lastFetchedProduct!);
          }

          if (_queuedCartProduct != null) {
            await addToCart(_queuedCartProduct!);
            _queuedCartProduct = null;
          }

          await _processQueuedProduct();
        }

      }

    });
  }

  

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

}
