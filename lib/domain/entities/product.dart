import 'package:uuid/uuid.dart';

class Product {
  final String id;
  final String name;
  final double price;

  Product({String? id, required this.name, required this.price})
    : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price};
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
    );
  }
}
