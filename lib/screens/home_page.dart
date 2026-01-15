import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../models/customer.dart';
import '../main.dart';
import 'customer_details_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customerProvider);
    final stats = ref.watch(totalStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Baki Khata'),
        actions: [
          IconButton(
            onPressed: () => _showAddCustomerDialog(context, ref),
            icon: const Icon(Icons.person_add_outlined, size: 28),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Balance Overview',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(stats['due']),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _statLabel('SELL', stats['sell']!),
                      const SizedBox(width: 24),
                      _statLabel('PAID', stats['paid']!),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                  return _CustomerTile(customer: customer);
                }, childCount: customers.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statLabel(String label, double amount) {
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
        Text(
          simpleCurrencyFormat.format(amount),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showAddCustomerDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Name',
                border: UnderlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                hintText: 'Phone',
                border: UnderlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
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
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                final customer = Customer(
                  name: nameController.text,
                  phone: phoneController.text,
                );
                ref.read(customerProvider.notifier).addCustomer(customer);
                Navigator.pop(context);
              }
            },
            child: const Text(
              'ADD',
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
}

class _CustomerTile extends ConsumerWidget {
  final Customer customer;
  const _CustomerTile({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(customerDueProvider(customer.id));

    return Dismissible(
      key: Key(customer.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade50,
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) {
        ref.read(customerProvider.notifier).deleteCustomer(customer.id);
        ref
            .read(transactionProvider.notifier)
            .deleteTransactionsForCustomer(customer.id);
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerDetailsPage(customer: customer),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.black,
                radius: 20,
                child: Text(
                  customer.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      customer.phone,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(due),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: due > 0
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                  const Text(
                    'DUE',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
