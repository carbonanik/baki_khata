import 'package:baki_khata/domain/entities/customer.dart';
import 'package:baki_khata/domain/entities/transaction.dart';
import 'package:baki_khata/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'add_sell_page.dart';
import '../widgets/customer/customer_summary_card.dart';
import '../widgets/customer/transaction_tile.dart';
import '../widgets/dialogs/add_payment_dialog.dart';
import '../widgets/dialogs/transaction_details_dialog.dart';

class CustomerDetailsPage extends ConsumerStatefulWidget {
  final Customer customer;
  const CustomerDetailsPage({super.key, required this.customer});

  @override
  ConsumerState<CustomerDetailsPage> createState() =>
      _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends ConsumerState<CustomerDetailsPage> {
  bool _showAllTransactions = false;

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final transactions = ref.watch(customerTransactionsProvider(customer.id));
    final due = ref.watch(customerDueProvider(customer.id));

    double totalSell = 0;
    double totalPaid = 0;
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.sell) {
        totalSell += transaction.totalAmount;
      }
      totalPaid += transaction.paidAmount;
    }

    final visibleTransactions = _showAllTransactions
        ? transactions
        : transactions.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE2ECFF),
              child: Text(
                customer.name.trim().isEmpty
                    ? '?'
                    : customer.name.trim()[0].toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF1557D5),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    customer.phone,
                    style: const TextStyle(
                      color: Color(0xFF8792A2),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AddPaymentDialog(customer: customer),
                ),
                icon: const Icon(Icons.payments_outlined, size: 20),
                label: const Text('Add Payment'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF111827),
                  side: const BorderSide(color: Color(0xFF222222)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddSellPage(customer: customer),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 22),
                label: const Text('Add Sell'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111315),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomerSummaryCard(
              totalSell: totalSell,
              totalPaid: totalPaid,
              due: due,
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                if (transactions.length > 3)
                  TextButton(
                    onPressed: () => setState(
                      () => _showAllTransactions = !_showAllTransactions,
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF244674),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(
                      _showAllTransactions ? 'Show Less' : 'View All',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9EACC2).withValues(alpha: 0.12),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: transactions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(
                          'No transactions yet',
                          style: TextStyle(
                            color: Color(0xFF8792A2),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: visibleTransactions.map((transaction) {
                        return InkWell(
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) => TransactionDetailsDialog(
                              transaction: transaction,
                              allTransactions: transactions,
                            ),
                          ),
                          child: TransactionTile(transaction: transaction),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
