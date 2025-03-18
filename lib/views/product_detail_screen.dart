// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product.image, height: 200, width: double.infinity, fit: BoxFit.cover),
            SizedBox(height: 10),
            Text(product.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("\$${product.price.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Descripción del producto...", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
