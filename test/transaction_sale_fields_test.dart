import 'package:baki_khata/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sale transaction fields', () {
    test('reads older transactions without quantity, unit, or discount', () {
      final transaction = Transaction.fromJson({
        'id': 'old-sale',
        'shopId': 'shop',
        'customerId': 'customer',
        'type': 'sell',
        'items': [
          {'name': 'চাল', 'price': 120.0},
        ],
        'totalAmount': 120.0,
        'paidAmount': 20.0,
        'timestamp': '2026-10-15T12:00:00.000',
      });

      expect(transaction.discountAmount, 0);
      expect(transaction.grossAmount, 120);
      expect(transaction.dueAmount, 100);
      expect(transaction.items!.single.quantity, 1);
      expect(transaction.items!.single.unit, 'পিস');
      expect(transaction.items!.single.unitPrice, 120);
    });

    test('persists quantity, unit, and discount and computes net due', () {
      final transaction = Transaction(
        shopId: 'shop',
        customerId: 'customer',
        type: TransactionType.sell,
        items: [
          SaleItem(
            name: 'সয়াবিন তেল',
            price: 500,
            quantity: 2,
            unit: 'লিটার',
            unitPrice: 250,
          ),
        ],
        totalAmount: 450,
        discountAmount: 50,
        paidAmount: 100,
        timestamp: DateTime(2026, 10, 15),
      );

      final restored = Transaction.fromJson(transaction.toJson());

      expect(restored.discountAmount, 50);
      expect(restored.grossAmount, 500);
      expect(restored.dueAmount, 350);
      expect(restored.items!.single.quantity, 2);
      expect(restored.items!.single.unit, 'লিটার');
      expect(restored.items!.single.price, 500);
      expect(restored.items!.single.unitPrice, 250);
    });
  });
}
