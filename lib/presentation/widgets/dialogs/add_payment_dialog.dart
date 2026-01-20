import 'package:baki_khata/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/customer.dart';

class AddPaymentDialog extends ConsumerStatefulWidget {
  final Customer customer;
  const AddPaymentDialog({super.key, required this.customer});

  @override
  ConsumerState<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends ConsumerState<AddPaymentDialog> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Payment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: amountController,
            decoration: const InputDecoration(
              hintText: 'Amount (৳)',
              border: UnderlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(
              hintText: 'Note (optional)',
              border: UnderlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () {
            final amount = double.tryParse(amountController.text);
            if (amount != null && amount > 0) {
              final transaction = Transaction(
                shopId: '', // Provider will set this
                customerId: widget.customer.id,
                type: TransactionType.payment,
                totalAmount: 0,
                paidAmount: amount,
                note: noteController.text.trim().isEmpty
                    ? null
                    : noteController.text.trim(),
              );
              ref
                  .read(transactionProvider.notifier)
                  .addTransaction(transaction);
              Navigator.pop(context);
            }
          },
          child: const Text(
            'SAVE',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
