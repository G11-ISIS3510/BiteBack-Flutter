class Product {
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
    required this.businessId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      category: json['category'],
      name: json['name'],
      image: json['image'],
      categoryImage: json['categoryImage'],
      price: (json['price'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      description: json['description'],
      expirationDate: DateTime.parse(json['expirationDate']),
      businessId: json['businessId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'image': image,
      'categoryImage': categoryImage,
      'price': price,
      'discount': discount,
      'description': description,
      'expirationDate': expirationDate.toIso8601String(),
      'businessId': businessId,
    };
  }
}
