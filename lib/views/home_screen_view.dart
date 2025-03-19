// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use, unnecessary_brace_in_string_interps

import 'package:biteback/widgets/custom_bottom_navbar.dart';
import 'package:biteback/widgets/explore_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../repositories/analytics_repository.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/search_bar_with_voice.dart';
import '../widgets/discount_banner.dart';
import 'product_detail_screen.dart'; 

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        bottomNavigationBar: CustomBottomNavBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SearchBarWithVoice(),
                DiscountBanner(),
                ExploreBanners(),
                _buildCategories(),
                _buildAllProducts(), // Nueva función que ahora maneja la búsqueda
                _buildNearbyProducts(),
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

Widget _categoryCard(String category, String selectedCategory, Function(String) onSelected) {
  return GestureDetector(
    onTap: () {
      onSelected(category);
      
      // Llamar al método de AnalyticsRepository para registrar el clic
      AnalyticsRepository().addFilterButtonsUsage(category);
    },
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 6),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: category == selectedCategory ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: category == selectedCategory ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}


  Widget _buildNearbyProducts() {
  return Consumer<HomeViewModel>(
    builder: (context, viewModel, child) {
      if (viewModel.nearbyProducts.isEmpty) {
        return Center(child: CircularProgressIndicator()); // Muestra carga si no hay productos
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              "Productos cercanos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: viewModel.nearbyProducts.map((product) {
                return _productCard(product, context);
              }).toList(),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildAllProducts() {
  return Consumer<HomeViewModel>(
    builder: (context, viewModel, child) {
      final List<Product> productsToShow = viewModel.filteredProducts;

      if (productsToShow.isEmpty) {
        return Center(child: Text("No se encontraron productos."));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              viewModel.searchQuery.isNotEmpty || viewModel.selectedCategory.isNotEmpty
                  ? "Resultados de la búsqueda"
                  : "Todos los productos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: productsToShow.map((product) {
                return _productCard(product, context);
              }).toList(),
            ),
          ),
        ],
      );
    },
  );
}

Widget _productCard(Product product, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        ),
      );
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: EdgeInsets.only(right: 10),
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(product.image, height: 100, width: 160, fit: BoxFit.cover),
                ),
                if (product.discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${product.discount.toInt()}% off",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("\$${product.price.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
