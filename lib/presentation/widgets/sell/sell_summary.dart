import 'package:baki_khata/main.dart';
import 'package:flutter/material.dart';

class SellSummary extends StatelessWidget {
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final TextEditingController paidController;
  final TextEditingController noteController;
  final VoidCallback onPaidChanged;

  const SellSummary({
    super.key,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.paidController,
    required this.noteController,
    required this.onPaidChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _summaryRow('Total Amount', totalAmount, isBold: true),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Paid Amount',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(
              width: 100,
              child: TextField(
                controller: paidController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: '৳ ',
                  isDense: true,
                  border: UnderlineInputBorder(),
                ),
                onChanged: (_) => onPaidChanged(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Add a note (optional)',
            isDense: true,
            border: UnderlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        _summaryRow(
          'Due Amount',
          dueAmount,
          color: dueAmount > 0 ? Colors.red : Colors.green,
        ),
      ],
    );
  }

  Widget _summaryRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? Colors.black : Colors.grey,
          ),
        ),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: FontWeight.w800,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
