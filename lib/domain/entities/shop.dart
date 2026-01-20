import 'package:uuid/uuid.dart';

class Shop {
  final String id;
  final String name;
  final String? address;
  final String? phone;

  Shop({String? id, required this.name, this.address, this.phone})
    : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'address': address, 'phone': phone};
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
    );
  }

  Shop copyWith({String? name, String? address, String? phone}) {
    return Shop(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }
}
