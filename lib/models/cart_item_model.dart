class CartItem {
  final String productId;
  final String name;
  final double price;         // Precio original
  final double discount;      // Descuento en porcentaje (ej. 35.0)
  final String image;
  final int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.discount,
    required this.image,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'name': name,
      'price': price,
      'discount': discount,
      'image': image,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['product_id'],
      name: map['name'],
      price: map['price'].toDouble(),
      discount: map['discount'].toDouble(),
      image: map['image'],
      quantity: map['quantity'] ?? 1,
    );
  }

  double get finalPrice => price * (1 - discount / 100);
}
