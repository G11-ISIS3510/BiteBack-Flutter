import 'package:biteback/models/product_model.dart';

class Business {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  final double rating;
  final String image;
  final int startHour;
  final int closeHour;
  List<Product> products;

  Business({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.rating,
    required this.image,
    required this.startHour,
    required this.closeHour,
    required this.products,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'],
      rating: (json['rating'] as num).toDouble(),
      image: json['image'],
      startHour: json['startHour'],
      closeHour: json['closeHour'],
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => Product.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'rating': rating,
      'image': image,
      'startHour': startHour,
      'closeHour': closeHour,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }
}
