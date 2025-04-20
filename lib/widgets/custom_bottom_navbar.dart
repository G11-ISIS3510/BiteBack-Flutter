// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use

import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), // Bordes redondeados
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
  backgroundColor: Colors.white,
  type: BottomNavigationBarType.fixed,
  elevation: 0,
  selectedItemColor: Colors.orange,
  unselectedItemColor: Colors.grey,
  showSelectedLabels: true,
  showUnselectedLabels: true,
  onTap: (index) {
    if (index == 2) {
      Navigator.pushNamed(context, '/cart');
    }
    // Aquí podrías manejar los otros tabs si los usas luego
  },
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home, size: 28),
      label: "Home",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.sync, size: 28),
      label: "Misterio?",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart, size: 28),
      label: "Carrito",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.emoji_emotions, size: 28),
      label: "Perfil",
    ),
  ],
),

    );
  }
}
