import 'package:flutter/material.dart';
import '../../../domain/entities/transaction.dart';
import '../../../main.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isSell = transaction.type == TransactionType.sell;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSell ? Colors.orange.shade50 : Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSell ? Icons.shopping_basket_outlined : Icons.payments_outlined,
              size: 20,
              color: isSell ? Colors.orange.shade800 : Colors.green.shade800,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSell ? 'Sale' : 'Payment Received',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  dateFormat.format(transaction.timestamp),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                if (transaction.note != null && transaction.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      transaction.note!,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(
                  isSell ? transaction.totalAmount : transaction.paidAmount,
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isSell ? Colors.black : Colors.green.shade700,
                ),
              ),
              if (isSell && transaction.dueAmount > 0)
                Text(
                  'DUE: ${currencyFormat.format(transaction.dueAmount)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
