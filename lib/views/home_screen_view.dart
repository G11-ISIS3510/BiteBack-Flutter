// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use, unnecessary_brace_in_string_interps

import 'package:biteback/widgets/explore_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/search_bar_with_voice.dart';
import '../widgets/discount_banner.dart'; // Importa el nuevo banner

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        bottomNavigationBar: _buildBottomNavigationBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SearchBarWithVoice(
                  onSearch: (query) {
                    Provider.of<HomeViewModel>(context, listen: false)
                        .filterRestaurants(query);
                  },
                ),
                DiscountBanner(), // Aquí usamos el nuevo banner
                ExploreBanners(),
                _buildCategories(),
                _buildNearbyProducts(),
                _buildRecommendedForYou(),
                _buildCorrientazos(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
  return Consumer<HomeViewModel>(
    builder: (context, viewModel, child) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8), // Alineación con la barra de búsqueda
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola, ${viewModel.userName}!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              viewModel.address,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      );
    },
  );
}


 Widget _buildCategories() {
  return Consumer<HomeViewModel>(
    builder: (context, viewModel, child) {
      if (viewModel.categories.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              "Categorías",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: viewModel.categories.map((category) {
                return _categoryCard(category, viewModel.selectedCategory, (selected) {
                  viewModel.setSelectedCategory(selected);
                });
              }).toList(),
            ),
          ),
        ],
      );
    },
  );
}

Widget _categoryCard(String title, String selectedCategory, Function(String) onSelect) {
  bool isSelected = title == selectedCategory;

  return GestureDetector(
    onTap: () => onSelect(title),
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange : Colors.white, // Fondo cambia al seleccionar
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.black, // Texto cambia al seleccionar
        ),
      ),
    ),
  );
}


  Widget _buildNearbyProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Productos cercanos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _productCard("Filete con papas", "\$25.000", "assets/filete_papas.png", 30),
              _productCard("Gulas con cilantro", "\$15.000", "assets/gulas_cilantro.png", 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _productCard(String name, String price, String imagePath, int discount) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.asset(imagePath, height: 100, width: 160, fit: BoxFit.cover),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: Colors.red,
                  child: Text("${discount}% off", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(price, style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecommendedForYou() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recomendado para ti", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        _productCard("Magnificare", "\$25.000", "assets/magnificare.png", 35),
      ],
    );
  }

  Widget _buildCorrientazos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Corrientazos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        _productCard("Bandeja paisa", "\$30.000", "assets/bandeja_paisa.png", 14),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BottomNavigationBar(
          backgroundColor: Colors.grey[300],
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.category), label: "Categories"),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
