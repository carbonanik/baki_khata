import 'package:baki_khata/domain/entities/customer.dart';
import 'package:baki_khata/domain/entities/transaction.dart';
import 'package:baki_khata/main.dart';
import 'package:baki_khata/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screens/customer_details_page.dart';

class CustomerTile extends ConsumerWidget {
  final Customer customer;

  const CustomerTile({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(customerDueProvider(customer.id));
    final transactions = ref.watch(customerTransactionsProvider(customer.id));
    final salesCount = transactions
        .where((transaction) => transaction.type == TransactionType.sell)
        .length;
    final latestTransaction = transactions.isEmpty ? null : transactions.first;
    final daysSinceUpdate = latestTransaction == null
        ? null
        : DateTime.now().difference(latestTransaction.timestamp).inDays;
    final avatarStyle = _avatarStyle(customer.name);
    final updatedLabel = switch (daysSinceUpdate) {
      null => 'এখনো লেনদেন নেই',
      <= 0 => 'আজ আপডেট',
      1 => 'গতকাল আপডেট',
      final days => '$days দিন আগে',
    };

    return Dismissible(
      key: Key(customer.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Customer?'),
              content: Text(
                'Are you sure you want to delete ${customer.name}?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'DELETE',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (_) {
        ref.read(customerProvider.notifier).deleteCustomer(customer.id);
        ref
            .read(transactionProvider.notifier)
            .deleteTransactionsForCustomer(customer.id);
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerDetailsPage(customer: customer),
              ),
            );
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 112),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9EDF2)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x080F2945),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: avatarStyle.background,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    customer.name.isEmpty
                        ? '?'
                        : customer.name[0].toUpperCase(),
                    style: TextStyle(
                      color: avatarStyle.foreground,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customer.phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF7D8795),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 10,
                        runSpacing: 3,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _Metadata(
                            icon: Icons.shopping_bag_outlined,
                            label: '$salesCount বিক্রয়',
                          ),
                          const Text(
                            '•',
                            style: TextStyle(
                              color: Color(0xFF7D8795),
                              fontSize: 11,
                            ),
                          ),
                          _Metadata(
                            icon: Icons.access_time_rounded,
                            label: updatedLabel,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        currencyFormat.format(due),
                        style: TextStyle(
                          color: due > 0
                              ? const Color(0xFFB0003A)
                              : const Color(0xFF006B4F),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: due > 0
                            ? const Color(0xFFFFE2E7)
                            : const Color(0xFFDDF8EB),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        due > 0 ? 'বাকি আছে' : 'পরিশোধিত',
                        style: TextStyle(
                          color: due > 0
                              ? const Color(0xFFB0003A)
                              : const Color(0xFF006B4F),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5EEFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF34466D),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _AvatarStyle _avatarStyle(String name) {
    final palette = [
      const _AvatarStyle(Color(0xFFE7F0FF), Color(0xFF1768E8)),
      const _AvatarStyle(Color(0xFFE5F8EA), Color(0xFF209A4B)),
      const _AvatarStyle(Color(0xFFF0ECFF), Color(0xFF6540C8)),
      const _AvatarStyle(Color(0xFFFFF1DE), Color(0xFFD38313)),
    ];
    return palette[name.isEmpty ? 0 : name.codeUnitAt(0) % palette.length];
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF697586)),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF697586), fontSize: 11),
        ),
      ],
    );
  }
}

class _AvatarStyle {
  const _AvatarStyle(this.background, this.foreground);

  final Color background;
  final Color foreground;
}
