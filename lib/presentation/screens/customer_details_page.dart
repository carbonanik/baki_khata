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
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AddPaymentDialog(customer: customer),
                  ),
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
              child: CustomerSummaryCard(
                totalSell: totalSell,
                totalPaid: totalPaid,
                due: due,
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
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => TransactionDetailsDialog(
                        transaction: transaction,
                        allTransactions: transactions,
                      ),
                    ),
                    child: TransactionTile(transaction: transaction),
                  );
                }, childCount: transactions.length),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}
