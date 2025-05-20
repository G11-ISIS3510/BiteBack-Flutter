class CartItem {
  final String productId;
  final String name;
  final double price;         // Precio original
  final double discount;      // Descuento en porcentaje (ej. 35.0)
  final String image;
  final int quantity;
  final bool isMysteryBox;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.discount,
    required this.image,
    this.quantity = 1,
    this.isMysteryBox = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'name': name,
      'price': price,
      'discount': discount,
      'image': image,
      'quantity': quantity,
      'isMysteryBox': isMysteryBox,
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
      isMysteryBox: map['isMysteryBox'] ?? false,
    );
  }

  double get finalPrice => price * (1 - discount / 100);
}
