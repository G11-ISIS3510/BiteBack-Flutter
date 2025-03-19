import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../main.dart';
import '../models/product_model.dart';
import '../viewmodels/product_detail_viewmodel.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  
@override
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final isDarkMode = themeProvider.isDarkMode;

  // ✅ Corrected discount calculation
  final double discountedPrice = product.price - ((product.price * product.discount)/100);

  return ChangeNotifierProvider(
    create: (_) => ProductDetailViewModel(),
    child: Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Consumer<ProductDetailViewModel>(
        builder: (context, viewModel, child) {
          Geolocator.getCurrentPosition().then((position) {
            viewModel.fetchBusinessDetails(product, position);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),

                // ✅ Product Name
                Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),

                // ✅ Corrected Price and Discount Display
                Row(
                  children: [
                    Text(
                      "\$${discountedPrice.toStringAsFixed(2)}", // 🔹 Corrected Calculation
                      style: const TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "\$${product.price.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ✅ Updated Info Bar
                _buildInfoBar(product, viewModel.businessName, viewModel.businessDistance, context),

                const SizedBox(height: 20),


                Text(
                  "Descripción",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    
                  ),
                ),

                const SizedBox(height: 10),

                // ✅ Product Description
                Text(product.description, style: const TextStyle(fontSize: 16)),

                const SizedBox(height: 20),

                // ✅ Purchase Button
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Center(
                    child: Text("Me lo merco →", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

  Widget _buildInfoBar(Product product, String businessName, String businessDistance, BuildContext context) {
  final theme = Theme.of(context); // ✅ Get ThemeData
  
  final now = DateTime.now();
  final remainingTime = product.expirationDate.difference(now);
  final remainingHours = remainingTime.inHours;
  final discountPercentage = (product.discount).toStringAsFixed(0); // ✅ Convert to %

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(
      color: theme.brightness == Brightness.dark ? Colors.black87 : Colors.white, // ✅ Automatic light/dark mode
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _infoCard("$remainingHours horas", "Para vencer", theme),
        _infoCard("$discountPercentage%", "Descuento", theme),
        _infoCard(businessName, "Tienda", theme),
        _infoCard(businessDistance, "Distancia", theme),
      ],
    ),
  );
}

// ✅ _infoCard() Uses Theme Colors Without Changing `main.dart`
Widget _infoCard(String value, String label, ThemeData theme) {
  final isDarkMode = theme.brightness == Brightness.dark;

  return Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black, // ✅ Text adapts automatically
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isDarkMode ? Colors.grey[300] : Colors.grey[700], // ✅ Subtitle adapts to theme
        ),
      ),
    ],
  );
}



}
