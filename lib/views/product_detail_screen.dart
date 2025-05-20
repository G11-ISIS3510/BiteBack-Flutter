// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:biteback/cache/custom_image_cache_manager.dart';
import 'package:biteback/models/user_location_model.dart';
import 'package:biteback/views/map_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../viewmodels/product_detail_viewmodel.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductDetailViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ProductDetailViewModel();
    viewModel.init(widget.product); // Se obtiene la ubicación y detalles del negocio
  }

  @override
  Widget build(BuildContext context) {
  final double discountedPrice =
      widget.product.price - ((widget.product.price * widget.product.discount) / 100);

  return ChangeNotifierProvider(
    create: (_) => viewModel,
    child: Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: SafeArea( 
        child: Consumer<ProductDetailViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.offlineQueuedMessageShown) {
              Future.microtask(() {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("El producto será agregado al carrito cuando se restablezca la conexión."),
                    duration: Duration(seconds: 4),
                    ),
                );
                viewModel.resetOfflineMessageFlag();
              });

            }

            if (viewModel.productAdded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Producto agregado al carrito")),);
                viewModel.resetProductAdded();
              });
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: widget.product.image,
                      cacheManager: CustomImageCacheManager.instance,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => const SizedBox(
                        height: 200,
                        child: Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Product Name
                  Text(widget.product.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),

                  // Price and Discount Display
                  Row(
                    children: [
                      Text(
                        "\$${discountedPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "\$${widget.product.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Updated Info Bar
                  _buildInfoBar(widget.product, viewModel.businessName, viewModel.businessDistance, context),   

                  const SizedBox(height: 20),

                  Text(
                    "Descripción",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Product Description
                  Text(widget.product.description, style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      if (viewModel.businessLatitude != null && viewModel.businessLongitude != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MapScreen(
                              restaurantLocation: UserLocation(
                                latitude: viewModel.businessLatitude!,
                                longitude: viewModel.businessLongitude!,
                              ),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Ubicación del negocio no disponible")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Center(
                      child: Text(
                        "Ver en el mapa",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Purchase Button
                  
                  ElevatedButton(
                  onPressed: () => viewModel.addToCart(widget.product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Center(
                    child: Text(
                      "Me lo merco →",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  ),
                  
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}

  Widget _buildInfoBar(Product product, String businessName, String businessDistance, BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final remainingTime = product.expirationDate.difference(now);
    final remainingHours = remainingTime.inHours;
    final discountPercentage = (product.discount).toStringAsFixed(2);

    final infoItems = [
      _infoCard("$remainingHours horas", "Para vencer", theme),
      _infoCard("$discountPercentage%", "Descuento", theme),
      _infoCard(businessName, "Tienda", theme),
      if (viewModel.hasConnection)
        _infoCard(businessDistance, "Distancia", theme),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 400) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? Colors.black87 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: infoItems,
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? Colors.black87 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [infoItems[0], infoItems[1]],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [infoItems[2], infoItems[3]],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _infoCard(String value, String label, ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
