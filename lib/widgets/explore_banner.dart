// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/restaurants_viewmodel.dart';
import '../views/restaurants_listing_view.dart'; // Importar la nueva vista de restaurantes

class ExploreBanners extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Primer banner - Restaurantes
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (_) => RestaurantsViewModel(),
                    child: RestaurantsListingScreen(),
                  ),
                ),
              );
            },
            child: _buildExploreCard(
              title: "Restaurantes",
              subtitle: "Explorar más",
              backgroundColor: Color(0xFF0A0A15), // Fondo oscuro
              textColor: Colors.white,
              iconColor: Colors.orange,
            ),
          ),
        ),
        SizedBox(width: 12), // Espacio fijo en la mitad
        // Segundo banner - Supermercados (puedes agregar navegación si lo deseas)
        Expanded(
          child: GestureDetector(
            onTap: () {
              // Agregar navegación si creas una pantalla de supermercados
            },
            child: _buildExploreCard(
              title: "Supermercados",
              subtitle: "Explorar más",
              backgroundColor: Color(0xFFDFF5D2), // Fondo verde claro
              textColor: Colors.green[900]!,
              iconColor: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExploreCard({
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      height: 70, // Misma altura que el banner de descuento
      margin: EdgeInsets.symmetric(vertical: 4), // Separación vertical
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Ajusta padding
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // Centrar contenido verticalmente
        children: [
          Row(
            children: [
              Text(
                subtitle,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 14, color: iconColor),
            ],
          ),
          SizedBox(height: 4), // Espacio entre líneas
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16, // Tamaño ajustado
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
