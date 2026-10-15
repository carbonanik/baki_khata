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
  final _searchFocusNode = FocusNode();
  bool _sortByDue = true;
  _CustomerFilter _customerFilter = _CustomerFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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

    final customersWithDue = customers.where((customer) {
      return (dueByCustomer[customer.id] ?? 0) > 0;
    }).length;
    final paidCustomers = customers.length - customersWithDue;
    final visibleCustomers = customers.where((customer) {
      final matchesQuery =
          customer.name.toLowerCase().contains(query) ||
          customer.phone.toLowerCase().contains(query);
      final due = dueByCustomer[customer.id] ?? 0;
      final matchesFilter = switch (_customerFilter) {
        _CustomerFilter.all => true,
        _CustomerFilter.due => due > 0,
        _CustomerFilter.settled => due <= 0,
      };
      return matchesQuery && matchesFilter;
    }).toList()..sort((a, b) {
      if (_sortByDue) {
        return (dueByCustomer[b.id] ?? 0).compareTo(
          dueByCustomer[a.id] ?? 0,
        );
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddCustomerDialog(),
        ),
        backgroundColor: const Color(0xFF006B4F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(
          'নতুন কাস্টমার',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFE8EAF2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF006B4F),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(child: ShopSelector()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'কাস্টমার খুঁজুন',
                      child: _HeaderAction(
                        icon: Icons.search_rounded,
                        size: 40,
                        onPressed: () =>
                            _searchFocusNode.requestFocus(),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Tooltip(
                      message: 'নোটিফিকেশন',
                      child: _HeaderAction(
                        icon: Icons.notifications_none_rounded,
                        size: 40,
                        showBadge: true,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'নোটিফিকেশন এখনো চালু করা হয়নি',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 7),
                    const CircleAvatar(
                      radius: 19,
                      backgroundColor: Color(0xFFDDF8EB),
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFF006B4F),
                        size: 23,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 9, 16, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE8EAF2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          color: Color(0xFF006B4F),
                          size: 9,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'দোকান সক্রিয়',
                          style: TextStyle(
                            color: Color(0xFF285849),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: BalanceOverviewCard(
                stats: stats,
                customersWithDue: customersWithDue,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE8EAF2)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'কাস্টমারের নাম বা মোবাইল নম্বর খুঁজুন...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF929AA7),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF64736D),
                        size: 21,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 31,
                      ),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 19,
                              ),
                            ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 56,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _CustomerFilterChip(
                      label: 'সবাই',
                      count: customers.length,
                      selected: _customerFilter == _CustomerFilter.all,
                      onTap: () => setState(
                        () => _customerFilter = _CustomerFilter.all,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _CustomerFilterChip(
                      label: 'বাকি আছে',
                      count: customersWithDue,
                      selected: _customerFilter == _CustomerFilter.due,
                      onTap: () => setState(
                        () => _customerFilter = _CustomerFilter.due,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _CustomerFilterChip(
                      label: 'পরিশোধিত',
                      count: paidCustomers,
                      selected: _customerFilter == _CustomerFilter.settled,
                      onTap: () => setState(
                        () => _customerFilter = _CustomerFilter.settled,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 7, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Text(
                            'কাস্টমার তালিকা',
                            style: TextStyle(
                              color: Color(0xFF152337),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Icon(
                            Icons.circle,
                            color: Color(0xFF006B4F),
                            size: 5,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${visibleCustomers.length} জন',
                            style: const TextStyle(
                              color: Color(0xFF697586),
                              fontSize: 12,
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
                  ],
                ),
              ),
            ),
            if (visibleCustomers.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 90),
                    child: Text(
                      customers.isEmpty
                          ? 'এখনো কোনো কাস্টমার যোগ করা হয়নি'
                          : query.isNotEmpty
                              ? 'কোনো কাস্টমার পাওয়া যায়নি'
                              : _customerFilter == _CustomerFilter.due
                                  ? 'কোনো বাকি কাস্টমার নেই'
                                  : 'কোনো পরিশোধিত কাস্টমার নেই',
                      style: const TextStyle(color: Color(0xFF7D8795)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList.separated(
                  itemCount: visibleCustomers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
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

enum _CustomerFilter { all, due, settled }

class _CustomerFilterChip extends StatelessWidget {
  const _CustomerFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : const Color(0xFF35423D);
    return Material(
      color: selected ? const Color(0xFF006B4F) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? const Color(0xFF006B4F) : const Color(0xFFE8EAF2),
            ),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.18)
                      : const Color(0xFFF0F2F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF59636F),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.onPressed,
    this.size = 42,
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
              Icon(icon, size: 22, color: const Color(0xFF26352F)),
              if (showBadge)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB0003A),
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
        PopupMenuItem(value: true, child: Text('বাকি আগে')),
        PopupMenuItem(value: false, child: Text('নাম A–Z')),
      ],
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.swap_vert_rounded,
              color: Color(0xFF006B4F),
              size: 17,
            ),
            const SizedBox(width: 4),
            Text(
              dueFirst ? 'বাকি আগে' : 'নাম A–Z',
              style: const TextStyle(
                color: Color(0xFF285849),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF285849),
              size: 17,
            ),
          ],
        ),
      ),
    );
  }
}
