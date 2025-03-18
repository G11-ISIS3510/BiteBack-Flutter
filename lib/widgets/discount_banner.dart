// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class DiscountBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4), // Reduce el margen superior e inferior
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Reduce el padding vertical
      decoration: BoxDecoration(
        color: Color(0xFF0A0A15), // Fondo oscuro
        borderRadius: BorderRadius.circular(20), // Esquinas menos redondeadas para menor altura
      ),
      child: Row(
        children: [
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Reduce espacio extra innecesario
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16, // Reduce el tamaño de la fuente
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(text: "¡Hasta un "),
                      TextSpan(
                        text: "70%",
                        style: TextStyle(color: Colors.amber),
                      ),
                      TextSpan(text: " de descuento!"),
                    ],
                  ),
                ),
                SizedBox(height: 4), // Reduce espacio entre texto
                Text(
                  "Comida con grandes descuentos",
                  style: TextStyle(color: Colors.white70, fontSize: 12), // Fuente más pequeña
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orangeAccent,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduce el tamaño del botón
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Botón más compacto
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Ver", style: TextStyle(fontSize: 12)), // Texto más pequeño
                Icon(Icons.arrow_forward, size: 14), // Icono más pequeño
              ],
            ),
          ),
        ],
      ),
    );
  }
}
