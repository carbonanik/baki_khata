import 'package:uuid/uuid.dart';

enum TransactionType { sell, payment }

class SaleItem {
  final String name;

  /// The line subtotal for this item, after multiplying unit price by quantity.
  final double price;
  final double quantity;
  final String unit;
  final double unitPrice;

  SaleItem({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.unit = 'পিস',
    double? unitPrice,
  }) : unitPrice = unitPrice ?? (quantity == 0 ? price : price / quantity);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
    };
  }

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      unit: json['unit'] as String? ?? 'পিস',
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
    );
  }
}

class Transaction {
  final String id;
  final String shopId;
  final String customerId;
  final TransactionType type;
  final List<SaleItem>? items; // Only for sell
  final double totalAmount;
  final double discountAmount;
  final double paidAmount;
  final String? note;
  final DateTime timestamp;

  Transaction({
    String? id,
    required this.shopId,
    required this.customerId,
    required this.type,
    this.items,
    required this.totalAmount,
    this.discountAmount = 0,
    required this.paidAmount,
    this.note,
    DateTime? timestamp,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  double get grossAmount => totalAmount + discountAmount;

  double get dueAmount => totalAmount - paidAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'customerId': customerId,
      'type': type.name,
      'items': items?.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'paidAmount': paidAmount,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      shopId: json['shopId'] ?? 'default_shop', // Migration fallback
      customerId: json['customerId'],
      type: TransactionType.values.byName(json['type']),
      items: (json['items'] as List?)
          ?.map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: json['totalAmount'].toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      paidAmount: json['paidAmount'].toDouble(),
      note: json['note'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
