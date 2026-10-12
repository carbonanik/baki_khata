import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/home/balance_overview_card.dart';
import '../widgets/home/customer_tile.dart';
import '../widgets/home/shop_selector.dart';
import '../widgets/dialogs/add_customer_dialog.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchController = TextEditingController();
  bool _showSearch = false;
  bool _sortByDue = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerProvider);
    final stats = ref.watch(totalStatsProvider);
    final transactions = ref.watch(transactionProvider);
    final query = _searchController.text.trim().toLowerCase();

    final dueByCustomer = <String, double>{};
    for (final transaction in transactions) {
      dueByCustomer.update(
        transaction.customerId,
        (due) => due + transaction.totalAmount - transaction.paidAmount,
        ifAbsent: () => transaction.totalAmount - transaction.paidAmount,
      );
    }
    final visibleCustomers =
        customers.where((customer) {
          return customer.name.toLowerCase().contains(query) ||
              customer.phone.toLowerCase().contains(query);
        }).toList()..sort((a, b) {
          if (_sortByDue) {
            return (dueByCustomer[b.id] ?? 0).compareTo(
              dueByCustomer[a.id] ?? 0,
            );
          }
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
    final customersWithDue = customers.where((customer) {
      return (dueByCustomer[customer.id] ?? 0) > 0;
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddCustomerDialog(),
        ),
        child: const Icon(Icons.person_add_alt_1_outlined),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 11, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 51,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE7EDF5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 35,
                              height: 35,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F1FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.storefront_outlined,
                                color: Color(0xFF1463D9),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(child: ShopSelector()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _HeaderAction(
                      icon: Icons.search_rounded,
                      onPressed: _toggleSearch,
                    ),
                    const SizedBox(width: 8),
                    _HeaderAction(
                      icon: Icons.notifications_none_rounded,
                      showBadge: true,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Notifications are not available yet',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 19)),
            SliverToBoxAdapter(child: BalanceOverviewCard(stats: stats)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 29, 18, 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Customers',
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$customersWithDue ${customersWithDue == 1 ? 'customer' : 'customers'} with due',
                                style: const TextStyle(
                                  color: Color(0xFF7D8795),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _SortButton(
                          dueFirst: _sortByDue,
                          onChanged: (dueFirst) {
                            setState(() => _sortByDue = dueFirst);
                          },
                        ),
                        const SizedBox(width: 8),
                        _HeaderAction(
                          icon: Icons.search_rounded,
                          size: 46,
                          onPressed: _toggleSearch,
                        ),
                      ],
                    ),
                    if (_showSearch) ...[
                      const SizedBox(height: 11),
                      TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search customers',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: IconButton(
                            onPressed: _toggleSearch,
                            icon: const Icon(Icons.close_rounded),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (visibleCustomers.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Text(
                      customers.isEmpty
                          ? 'No customers yet'
                          : 'No customers found',
                      style: const TextStyle(color: Color(0xFF7D8795)),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                sliver: SliverList.separated(
                  itemCount: visibleCustomers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 13),
                  itemBuilder: (context, index) =>
                      CustomerTile(customer: visibleCustomers[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.onPressed,
    this.size = 51,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 23, color: const Color(0xFF101820)),
              if (showBadge)
                Positioned(
                  top: 10,
                  right: 9,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF42B2B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.dueFirst, required this.onChanged});

  final bool dueFirst;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<bool>(
      initialValue: dueFirst,
      onSelected: onChanged,
      itemBuilder: (context) => const [
        PopupMenuItem(value: true, child: Text('Due first')),
        PopupMenuItem(value: false, child: Text('Name A–Z')),
      ],
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5EAF1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.swap_vert_rounded,
              color: Color(0xFF101820),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              dueFirst ? 'Due first' : 'Name A–Z',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
