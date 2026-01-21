import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final String shopId;
  final double amount;
  final String category;
  final String? note;
  final DateTime timestamp;

  Expense({
    String? id,
    required this.shopId,
    required this.amount,
    required this.category,
    this.note,
    DateTime? timestamp,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  Expense copyWith({
    String? id,
    String? shopId,
    double? amount,
    String? category,
    String? note,
    DateTime? timestamp,
  }) {
    return Expense(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'amount': amount,
      'category': category,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      shopId: json['shopId'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      note: json['note'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
