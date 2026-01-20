import 'package:flutter/material.dart';
import '../../../domain/entities/transaction.dart';
import '../../../main.dart';

class TransactionDetailsDialog extends StatelessWidget {
  final Transaction transaction;
  final List<Transaction> allTransactions;

  const TransactionDetailsDialog({
    super.key,
    required this.transaction,
    required this.allTransactions,
  });

  @override
  Widget build(BuildContext context) {
    if (transaction.type == TransactionType.sell) {
      return _buildSellDetails(context);
    } else {
      return _buildPaymentDetails(context);
    }
  }

  Widget _buildSellDetails(BuildContext context) {
    return AlertDialog(
      title: const Text('Sale Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateFormat.format(transaction.timestamp),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (transaction.items != null && transaction.items!.isNotEmpty)
            ...transaction.items!.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.name),
                    Text(currencyFormat.format(item.price)),
                  ],
                ),
              ),
            )
          else
            const Text('No items recorded'),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                currencyFormat.format(transaction.totalAmount),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _detailRow('Paid', transaction.paidAmount, color: Colors.green),
          const SizedBox(height: 8),
          _detailRow('Due', transaction.dueAmount, color: Colors.red),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE'),
        ),
      ],
    );
  }

  Widget _buildPaymentDetails(BuildContext context) {
    // Payment Details
    // Calculate due before this payment
    // Transactions are sorted newest first.
    // We need sum of all transactions strictly older than this one.

    double dueBefore = 0;

    for (var t in allTransactions) {
      if (t.timestamp.isBefore(transaction.timestamp)) {
        dueBefore += t.dueAmount;
      }
    }

    final paymentAmount = transaction.paidAmount;
    final dueAfter = dueBefore - paymentAmount;

    return AlertDialog(
      title: const Text('Payment Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateFormat.format(transaction.timestamp),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 20),
          _detailRow('Due before payment', dueBefore),
          const SizedBox(height: 8),
          _detailRow(
            'Payment Amount',
            paymentAmount,
            isBold: true,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _detailRow('Due after payment', dueAfter, isBold: true),
          if (transaction.note != null && transaction.note!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              "Note:",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(transaction.note!),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE'),
        ),
      ],
    );
  }

  Widget _detailRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
