class Product {

  // Atributos que modelan un producto en la aplicación
  final String id;
  final String category;
  final String name;
  final String image;
  final String categoryImage;
  final double price;
  final double discount;
  final String description;
  final DateTime expirationDate;
  final String businessId;

  Product({
    required this.id,
    required this.category,
    required this.name,
    required this.image,
    required this.categoryImage,
    required this.price,
    required this.discount,
    required this.description,
    required this.expirationDate,
    required this.businessId
  });
}