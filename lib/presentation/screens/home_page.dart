import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/home/balance_overview_card.dart';
import '../widgets/home/customer_tile.dart';
import '../widgets/dialogs/add_customer_dialog.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customerProvider);
    final stats = ref.watch(totalStatsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddCustomerDialog(),
        ),
        child: const Icon(Icons.person_add_outlined),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: BalanceOverviewCard(stats: stats)),
          if (customers.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No customers yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final customer = customers[index];
                  return CustomerTile(customer: customer);
                }, childCount: customers.length),
              ),
            ),
        ],
      ),
    );
  }
}
