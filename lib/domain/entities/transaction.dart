import 'package:uuid/uuid.dart';

enum TransactionType { sell, payment }

class SaleItem {
  final String name;
  final double price;

  SaleItem({required this.name, required this.price});

  Map<String, dynamic> toJson() {
    return {'name': name, 'price': price};
  }

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(name: json['name'], price: json['price'].toDouble());
  }
}

class Transaction {
  final String id;
  final String customerId;
  final TransactionType type;
  final List<SaleItem>? items; // Only for sell
  final double totalAmount;
  final double paidAmount;
  final String? note;
  final DateTime timestamp;

  Transaction({
    String? id,
    required this.customerId,
    required this.type,
    this.items,
    required this.totalAmount,
    required this.paidAmount,
    this.note,
    DateTime? timestamp,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  double get dueAmount => totalAmount - paidAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'type': type.name,
      'items': items?.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      customerId: json['customerId'],
      type: TransactionType.values.byName(json['type']),
      items: (json['items'] as List?)
          ?.map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: json['totalAmount'].toDouble(),
      paidAmount: json['paidAmount'].toDouble(),
      note: json['note'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
