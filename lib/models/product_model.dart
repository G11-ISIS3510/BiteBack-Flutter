import 'package:cloud_firestore/cloud_firestore.dart';

class Product {

  // Atributos que modelan un producto en la aplicación
  final String id;
  final String tag;
  final String name;
  final String image;
  final String tagImage;
  final double price;
  final double discount;
  final String description;
  final DateTime expirationDate;

  Product({
    required this.id,
    required this.tag,
    required this.name,
    required this.image,
    required this.tagImage,
    required this.price,
    required this.discount,
    required this.description,
    required this.expirationDate
  });

  // Convertir documento de Firestore en un Producto
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Product(
      id: doc.id,
      tag: data['tag'] ?? '',
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      tagImage: data['tagImage'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      expirationDate: (data['expirationDate'] as Timestamp).toDate(),
    );
  }




}