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
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSell
                  ? const Color(0xFFFFF2E2)
                  : const Color(0xFFEAF7EF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSell ? Icons.shopping_basket_outlined : Icons.payments_outlined,
              size: 24,
              color: isSell
                  ? const Color(0xFFF07816)
                  : const Color(0xFF279B51),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSell ? 'Sale' : 'Payment Received',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  dateFormat.format(transaction.timestamp),
                  style: const TextStyle(
                    color: Color(0xFF8792A2),
                    fontSize: 12,
                  ),
                ),
                if (isSell && transaction.items != null)
                  Text(
                    '${transaction.items!.length} '
                    '${transaction.items!.length == 1 ? 'item' : 'items'}',
                    style: const TextStyle(
                      color: Color(0xFF8792A2),
                      fontSize: 12,
                    ),
                  ),
                if (transaction.note != null && transaction.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      transaction.note!,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF8792A2),
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
                    fontSize: 11,
                    color: Color(0xFFE83F3C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: Color(0xFF8792A2), size: 22),
        ],
      ),
    );
  }
}
