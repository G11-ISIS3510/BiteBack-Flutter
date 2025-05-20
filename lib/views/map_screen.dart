import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/location_service.dart';
import '../models/user_location_model.dart';

class MapScreen extends StatefulWidget {
  
  final UserLocation restaurantLocation;

  const MapScreen({super.key, required this.restaurantLocation});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? userLatLng;
  late LatLng restaurantLatLng;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    restaurantLatLng =
        LatLng(widget.restaurantLocation.latitude, widget.restaurantLocation.longitude);
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    final position = await LocationService.getCurrentPosition();

    if (position != null) {
      setState(() {
        userLatLng = LatLng(position.latitude, position.longitude);
        loading = false;
      });
    } else {
      setState(() {
        loading = false; // Mostrar mapa solo con el restaurante
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Ubicación en el mapa")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: restaurantLatLng,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: restaurantLatLng,
                child: const Icon(Icons.restaurant, color: Colors.red, size: 40),
              ),
              if (userLatLng != null)
                Marker(
                  point: userLatLng!,
                  child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
