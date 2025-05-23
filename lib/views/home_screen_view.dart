// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use, unnecessary_brace_in_string_interps

import 'package:biteback/cache/custom_image_cache_manager.dart';
import 'package:biteback/services/navigation_service.dart';
import 'package:biteback/viewmodels/auth_viewmodel.dart';
import 'package:biteback/widgets/custom_bottom_navbar.dart';
import 'package:biteback/widgets/explore_banner.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../repositories/analytics_repository.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/search_bar_with_voice.dart';
import '../widgets/discount_banner.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        bottomNavigationBar: CustomBottomNavBar(),
        body: SafeArea(
          child: Consumer<HomeViewModel>(
            builder: (context, viewModel, child) {
              // Mostrar snackbar solo si las propiedades existen en tu ViewModel
              if (!viewModel.isOffline && viewModel.wasPreviouslyOffline) {
                Future.microtask(() {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Conexión recuperada"),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  viewModel.wasPreviouslyOffline = false;
                });
              }

              if (viewModel.isOffline && !viewModel.wasPreviouslyOffline) {
                viewModel.wasPreviouslyOffline = true;
              }

              return Column(
                children: [
                  if (viewModel.isOffline)
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: const [
                          Icon(Icons.wifi_off, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "No hay conexión a internet.",
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          SearchBarWithVoice(),
                          DiscountBanner(),
                          ExploreBanners(),
                          _buildCategories(),
                          _buildAllProducts(),
                          _buildRecentSearches(),
                          _buildNearbyProducts(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer2<HomeViewModel, AuthViewModel>(
      builder: (context, homeViewModel, authViewModel, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Hola, ${homeViewModel.userName}!",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    tooltip: "Cerrar sesión",
                    onPressed: () async {
                      await authViewModel.logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, "/login");
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                homeViewModel.address,
                style: const TextStyle(fontSize: 15, color: Colors.grey),
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
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                "Categorías",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: viewModel.categories.map((category) {
                  return _categoryCard(
                    category,
                    viewModel.selectedCategory,
                    (selected) {
                      viewModel.setSelectedCategory(selected);
                      AnalyticsRepository().addFilterButtonsUsage(selected);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _categoryCard(String category, String selectedCategory, Function(String) onSelected) {
    final bool isSelected = category == selectedCategory;

    return GestureDetector(
      onTap: () => onSelected(category),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyProducts() {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isOffline) {
          return _offlineNearbyProducts();
        }

        if (viewModel.nearbyProducts.isEmpty) {
          return _emptyNearbyProducts();
        }

        return _nearbyProductsList(viewModel.nearbyProducts, context);
      },
    );
  }

  Widget _offlineNearbyProducts() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Productos cercanos",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  "No se pueden calcular los productos cercanos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6),
                Text(
                  "Asegúrate de estar conectado a internet.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyNearbyProducts() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Productos cercanos",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  "No hay productos cercanos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6),
                Text(
                  "Intenta moverte a otra zona o vuelve a intentarlo más tarde.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nearbyProductsList(List<Product> products, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            "Productos cercanos",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: products.map((product) => _productCard(product, context)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAllProducts() {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final List<Product> productsToShow = viewModel.filteredProducts;

        if (productsToShow.isEmpty) {
          return const Center(child: Text("No se encontraron productos."));
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: productsToShow.map((product) => _productCard(product, context)).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentSearches() {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.recentSearchResults.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Búsquedas Recientes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear_all, color: Colors.red),
                    onPressed: () => viewModel.clearRecentSearches(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: viewModel.recentSearchResults.map((product) => _productCard(product, context)).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _productCard(Product product, BuildContext context) {
    return GestureDetector(
      onTap: () => NavigationService().navigateTo('/productDetail', arguments: product),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(right: 10),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      cacheManager: CustomImageCacheManager.instance,
                      height: 100,
                      width: 160,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const SizedBox(
                        height: 100,
                        width: 160,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => const SizedBox(
                        height: 100,
                        width: 160,
                        child: Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                  if (product.discount > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${product.discount.toInt()}% off",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "\$${product.price.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
