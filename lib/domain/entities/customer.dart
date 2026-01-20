import 'package:uuid/uuid.dart';

class Customer {
  final String id;
  final String shopId;
  final String name;
  final String phone;
  final String? address;

  Customer({
    String? id,
    required this.shopId,
    required this.name,
    required this.phone,
    this.address,
  }) : id = id ?? const Uuid().v4();

  Customer copyWith({
    String? shopId,
    String? name,
    String? phone,
    String? address,
  }) {
    return Customer(
      id: id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      shopId: json['shopId'] ?? 'default_shop', // Migration fallback
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
    );
  }
}
