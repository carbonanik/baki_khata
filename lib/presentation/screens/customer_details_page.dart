import 'package:baki_khata/domain/entities/customer.dart';
import 'package:baki_khata/domain/entities/transaction.dart';
import 'package:baki_khata/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/bengali_formatters.dart';
import '../../main.dart';
import 'add_sell_page.dart';
import '../widgets/dialogs/add_payment_dialog.dart';
import '../widgets/dialogs/transaction_details_dialog.dart';

const _pageBackground = Color(0xFFF8F9FF);
const _primaryGreen = Color(0xFF007A55);
const _darkGreen = Color(0xFF005F41);
const _textColor = Color(0xFF172333);
const _mutedColor = Color(0xFF75808D);

enum _TransactionFilter { all, dueSales, payments }

class CustomerDetailsPage extends ConsumerStatefulWidget {
  final Customer customer;
  const CustomerDetailsPage({super.key, required this.customer});

  @override
  ConsumerState<CustomerDetailsPage> createState() =>
      _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends ConsumerState<CustomerDetailsPage> {
  _TransactionFilter _filter = _TransactionFilter.all;

  Future<void> _openContact(Uri uri) async {
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        _showContactError('এই কাজটি করার জন্য কোনো অ্যাপ পাওয়া যায়নি।');
      }
    } on PlatformException {
      if (mounted) {
        _showContactError('কল বা মেসেজের অ্যাপটি খোলা যায়নি।');
      }
    }
  }

  void _showContactError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _callCustomer(String phone) async {
    final number = phone.trim();
    if (number.isEmpty) {
      _showContactError('এই কাস্টমারের ফোন নম্বর নেই।');
      return;
    }
    await _openContact(Uri(scheme: 'tel', path: number));
  }

  Future<void> _messageCustomer(String phone) async {
    var number = phone.replaceAll(RegExp(r'\D'), '');
    if (number.startsWith('0')) {
      number = '88$number';
    }
    if (number.isEmpty) {
      _showContactError('এই কাস্টমারের ফোন নম্বর নেই।');
      return;
    }
    await _openContact(Uri.https('wa.me', '/$number'));
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final transactions = ref.watch(customerTransactionsProvider(customer.id));
    final due = ref.watch(customerDueProvider(customer.id));

    var totalSell = 0.0;
    var totalPaid = 0.0;
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.sell) {
        totalSell += transaction.totalAmount;
      }
      totalPaid += transaction.paidAmount;
    }

    final paidRatio = totalSell == 0
        ? 0.0
        : ((totalSell - due) / totalSell).clamp(0.0, 1.0);
    final dueSales = transactions
        .where(
          (transaction) =>
              transaction.type == TransactionType.sell &&
              transaction.dueAmount > 0,
        )
        .toList();
    final payments = transactions
        .where((transaction) => transaction.type == TransactionType.payment)
        .toList();
    final visibleTransactions = switch (_filter) {
      _TransactionFilter.all => transactions,
      _TransactionFilter.dueSales => dueSales,
      _TransactionFilter.payments => payments,
    };

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _pageBackground,
        foregroundColor: _textColor,
        title: const Text(
          'কাস্টমারের বিবরণ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFDDF3EB),
              child: Text(
                customer.name.trim().isEmpty
                    ? '?'
                    : customer.name.trim()[0].toUpperCase(),
                style: const TextStyle(
                  color: _darkGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
                label: const Text('জমা যোগ করুন'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _darkGreen,
                  side: const BorderSide(color: _primaryGreen),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
                label: const Text('বাকি বিক্রি'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CustomerProfileCard(
              customer: customer,
              onCall: () => _callCustomer(customer.phone),
              onWhatsApp: () => _messageCustomer(customer.phone),
            ),
            const SizedBox(height: 16),
            _BalanceCard(
              due: due,
              totalSell: totalSell,
              totalPaid: totalPaid,
              paidRatio: paidRatio,
              lastTransaction: transactions.isEmpty
                  ? null
                  : transactions.first.timestamp,
            ),
            const SizedBox(height: 18),
            _TransactionFilterBar(
              selected: _filter,
              allCount: transactions.length,
              dueSalesCount: dueSales.length,
              paymentsCount: payments.length,
              onChanged: (filter) => setState(() => _filter = filter),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.history_rounded, color: _mutedColor, size: 21),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'লেনদেনের ইতিহাস',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (visibleTransactions.isNotEmpty)
                  Text(
                    formatBengaliDate(
                      visibleTransactions.first.timestamp,
                      includeTime: false,
                    ),
                    style: const TextStyle(
                      color: _mutedColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (visibleTransactions.isEmpty)
              _EmptyTransactions(filter: _filter)
            else
              ...visibleTransactions.map(
                (transaction) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TransactionCard(
                    transaction: transaction,
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => TransactionDetailsDialog(
                        transaction: transaction,
                        allTransactions: transactions,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomerProfileCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;

  const _CustomerProfileCard({
    required this.customer,
    required this.onCall,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 31,
                backgroundColor: const Color(0xFFDDF1EC),
                child: Text(
                  customer.name.trim().isEmpty
                      ? '?'
                      : customer.name.trim()[0].toUpperCase(),
                  style: const TextStyle(
                    color: _darkGreen,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        color: _textColor,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _ProfileDetail(
                      icon: Icons.phone_outlined,
                      text: customer.phone.isEmpty
                          ? 'ফোন নম্বর নেই'
                          : customer.phone,
                    ),
                    if (customer.address?.trim().isNotEmpty ?? false) ...[
                      const SizedBox(height: 5),
                      _ProfileDetail(
                        icon: Icons.location_on_outlined,
                        text: customer.address!.trim(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ContactButton(
                  icon: Icons.call_rounded,
                  label: 'কল করুন',
                  background: const Color(0xFFF0F3FF),
                  foreground: _darkGreen,
                  onPressed: onCall,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ContactButton(
                  icon: Icons.chat_rounded,
                  label: 'হোয়াটসঅ্যাপ',
                  background: const Color(0xFFE1F8EE),
                  foreground: _darkGreen,
                  onPressed: onWhatsApp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ProfileDetail({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _mutedColor),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: _mutedColor, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double due;
  final double totalSell;
  final double totalPaid;
  final double paidRatio;
  final DateTime? lastTransaction;

  const _BalanceCard({
    required this.due,
    required this.totalSell,
    required this.totalPaid,
    required this.paidRatio,
    required this.lastTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final hasDue = due > 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                hasDue ? Icons.error_outline_rounded : Icons.check_circle_outline,
                color: hasDue ? const Color(0xFFB20E42) : _primaryGreen,
                size: 21,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'বর্তমান মোট বাকি',
                  style: TextStyle(
                    color: _mutedColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (lastTransaction != null)
                Text(
                  'সর্বশেষ লেনদেন: ${formatBengaliDate(lastTransaction!, includeTime: false)}',
                  style: const TextStyle(color: _mutedColor, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            currencyFormat.format(due > 0 ? due : 0),
            style: TextStyle(
              color: hasDue ? const Color(0xFFB20E42) : _primaryGreen,
              fontSize: 31,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 19),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'পরিশোধের অগ্রগতি',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${toBengaliDigits((paidRatio * 100).round())}% পরিশোধিত',
                style: const TextStyle(
                  color: _darkGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: paidRatio,
              minHeight: 9,
              backgroundColor: const Color(0xFFE1E9F8),
              valueColor: const AlwaysStoppedAnimation(_primaryGreen),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _BalanceStat(
                  icon: Icons.shopping_bag_outlined,
                  label: 'মোট কেনাকাটা',
                  amount: totalSell,
                  color: const Color(0xFF4C78C2),
                  background: const Color(0xFFF0F3FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BalanceStat(
                  icon: Icons.payments_outlined,
                  label: 'মোট জমা',
                  amount: totalPaid,
                  color: _primaryGreen,
                  background: const Color(0xFFE5F8F0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final Color background;

  const _BalanceStat({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _mutedColor, fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  currencyFormat.format(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionFilterBar extends StatelessWidget {
  final _TransactionFilter selected;
  final int allCount;
  final int dueSalesCount;
  final int paymentsCount;
  final ValueChanged<_TransactionFilter> onChanged;

  const _TransactionFilterBar({
    required this.selected,
    required this.allCount,
    required this.dueSalesCount,
    required this.paymentsCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EDFC),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          _FilterOption(
            label: 'সব লেনদেন',
            count: allCount,
            selected: selected == _TransactionFilter.all,
            onPressed: () => onChanged(_TransactionFilter.all),
          ),
          _FilterOption(
            label: 'বাকি বিক্রি',
            count: dueSalesCount,
            selected: selected == _TransactionFilter.dueSales,
            onPressed: () => onChanged(_TransactionFilter.dueSales),
          ),
          _FilterOption(
            label: 'জমা / পরিশোধ',
            count: paymentsCount,
            selected: selected == _TransactionFilter.payments,
            onPressed: () => onChanged(_TransactionFilter.payments),
          ),
        ],
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onPressed;

  const _FilterOption({
    required this.label,
    required this.count,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 13),
            child: Center(
              child: Text(
                '$label (${toBengaliDigits(count)})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? _textColor : _mutedColor,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const _TransactionCard({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSale = transaction.type == TransactionType.sell;
    final due = transaction.dueAmount;
    final amount = isSale ? transaction.totalAmount : transaction.paidAmount;
    final amountText =
        '${isSale ? '+' : '-'}${currencyFormat.format(amount)}';
    final items = transaction.items ?? const <SaleItem>[];
    final itemNames = items
        .map(
          (item) =>
              '${item.name} · ${toBengaliDigits(item.quantity)} ${item.unit}',
        )
        .join('، ');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: _cardDecoration,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSale
                          ? const Color(0xFFFFE8E9)
                          : const Color(0xFFDDF8EC),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSale
                          ? Icons.receipt_long_rounded
                          : Icons.check_circle_rounded,
                      color: isSale
                          ? const Color(0xFFB20E42)
                          : _primaryGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSale ? 'বাকি বিক্রি' : 'নগদ জমা',
                          style: const TextStyle(
                            color: _textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatBengaliDate(transaction.timestamp),
                          style: const TextStyle(
                            color: _mutedColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        amountText,
                        style: TextStyle(
                          color: isSale
                              ? const Color(0xFFB20E42)
                              : _primaryGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      _StatusChip(
                        text: isSale
                            ? (due > 0
                                  ? 'বাকি ${currencyFormat.format(due)}'
                                  : 'পরিশোধিত')
                            : 'জমা হয়েছে',
                        isDue: isSale && due > 0,
                      ),
                    ],
                  ),
                ],
              ),
              if (isSale && itemNames.isNotEmpty) ...[
                const SizedBox(height: 13),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: _mutedColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          itemNames,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _textColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (isSale || (transaction.note?.isNotEmpty ?? false)) ...[
                const SizedBox(height: 12),
                if (isSale)
                  Row(
                    children: [
                      Expanded(
                        child: _TransactionAmount(
                          label: 'মোট বিল',
                          amount: transaction.grossAmount,
                        ),
                      ),
                      Expanded(
                        child: _TransactionAmount(
                          label: 'জমা',
                          amount: transaction.paidAmount,
                          color: _primaryGreen,
                        ),
                      ),
                      Expanded(
                        child: _TransactionAmount(
                          label: 'ছাড়',
                          amount: transaction.discountAmount,
                          color: const Color(0xFFB20E42),
                        ),
                      ),
                      Expanded(
                        child: _TransactionAmount(
                          label: 'বাকি',
                          amount: due > 0 ? due : 0,
                          color: const Color(0xFFB20E42),
                          alignEnd: true,
                        ),
                      ),
                    ],
                  )
                else
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      transaction.note!,
                      style: const TextStyle(
                        color: _mutedColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionAmount extends StatelessWidget {
  final String label;
  final double amount;
  final Color? color;
  final bool alignEnd;

  const _TransactionAmount({
    required this.label,
    required this.amount,
    this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: _mutedColor, fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            color: color ?? _textColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final bool isDue;

  const _StatusChip({required this.text, required this.isDue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDue ? const Color(0xFFFFE5E8) : const Color(0xFFDDF8EC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDue ? const Color(0xFF9B123D) : _darkGreen,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  final _TransactionFilter filter;

  const _EmptyTransactions({required this.filter});

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      _TransactionFilter.all => 'এখনো কোনো লেনদেন নেই',
      _TransactionFilter.dueSales => 'কোনো বাকি বিক্রি নেই',
      _TransactionFilter.payments => 'এখনো কোনো জমা লেনদেন নেই',
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: _cardDecoration,
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            color: Color(0xFFADB7C7),
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _mutedColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

final _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(17),
  boxShadow: [
    BoxShadow(
      color: const Color(0xFF8795AC).withValues(alpha: 0.1),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ],
);
