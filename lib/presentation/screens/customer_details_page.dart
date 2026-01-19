import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/transaction.dart';
import '../../main.dart';
import 'add_sell_page.dart';

class CustomerDetailsPage extends ConsumerWidget {
  final Customer customer;
  const CustomerDetailsPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(customerTransactionsProvider(customer.id));
    final due = ref.watch(customerDueProvider(customer.id));

    double totalSell = 0;
    double totalPaid = 0;
    for (var t in transactions) {
      if (t.type == TransactionType.sell) {
        totalSell += t.totalAmount;
        totalPaid += t.paidAmount;
      } else {
        totalPaid += t.paidAmount;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(customer.name)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showAddPaymentDialog(context, ref),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'ADD PAYMENT',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddSellPage(customer: customer),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'ADD SELL',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryItem('TOTAL SELL', totalSell),
                        _summaryItem('TOTAL PAID', totalPaid),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Color(0xFFE0E0E0)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CURRENT DUE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          currencyFormat.format(due),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: due > 0
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'TRANSACTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          if (transactions.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No transactions yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final transaction = transactions[index];
                  return InkWell(
                    onTap: () => _showTransactionDetails(
                      context,
                      transaction,
                      transactions,
                    ),
                    child: _TransactionTile(transaction: transaction),
                  );
                }, childCount: transactions.length),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          simpleCurrencyFormat.format(amount),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  void _showAddPaymentDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  customerId: customer.id,
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
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    Transaction transaction,
    List<Transaction> allTransactions,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        if (transaction.type == TransactionType.sell) {
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
        } else {
          // Payment Details
          // Calculate due before this payment
          // Transactions are sorted newest first.
          // We need sum of all transactions strictly older than this one.
          // Older transactions have higher indices in the sorted list.

          double dueBefore = 0;
          // We can find the index of current transaction
          // Since we passed the same instance from the list, identity check works
          // Or we can just filter by timestamp < current.timestamp

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
                if (transaction.note != null &&
                    transaction.note!.isNotEmpty) ...[
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
      },
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

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  const _TransactionTile({required this.transaction});

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
