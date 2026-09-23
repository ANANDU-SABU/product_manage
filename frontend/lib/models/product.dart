class Product {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }
}