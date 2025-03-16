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
}