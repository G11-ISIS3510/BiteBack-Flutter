import 'package:biteback/models/product_model.dart';

class Business {

  // Atributos que modelan un negocio en la aplicación
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  // A futuro toca cambiar el final, cuando se agregue la herramienta de reviews
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
    required this.products
  });

  // A futuro toca añadir el método para actualizar el rating
}