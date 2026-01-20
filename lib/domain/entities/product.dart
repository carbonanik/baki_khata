import 'package:uuid/uuid.dart';

class Product {
  final String id;
  final String shopId;
  final String name;
  final double price;

  Product({
    String? id,
    required this.shopId,
    required this.name,
    required this.price,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {'id': id, 'shopId': shopId, 'name': name, 'price': price};
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      shopId: json['shopId'] ?? 'default_shop', // Migration fallback
      name: json['name'],
      price: json['price'].toDouble(),
    );
  }
}
