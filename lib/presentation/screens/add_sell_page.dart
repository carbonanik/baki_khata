import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/utils/bengali_formatters.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/transaction.dart';
import '../../main.dart';
import '../providers/app_providers.dart';
import '../widgets/sell/sell_item_row.dart';
import '../widgets/sell/sell_item_row_data.dart';
import '../widgets/sell/sell_summary.dart';

const _pageBackground = Color(0xFFF8F9FF);
const _green = Color(0xFF006B4F);
const _ink = Color(0xFF172333);
const _muted = Color(0xFF75808D);

class AddSellPage extends ConsumerStatefulWidget {
  final Customer customer;
  const AddSellPage({super.key, required this.customer});

  @override
  ConsumerState<AddSellPage> createState() => _AddSellPageState();
}

class _AddSellPageState extends ConsumerState<AddSellPage> {
  final List<SaleItem> _items = [];
  SellItemRowData _draft = SellItemRowData();
  final discountController = TextEditingController(text: '০');
  final paidController = TextEditingController(text: '০');
  final noteController = TextEditingController();
  double grossAmount = 0;
  double discountAmount = 0;
  double totalAmount = 0;
  double paidAmount = 0;
  double dueAmount = 0;
  bool isFullPaid = false;
  bool hasExcessDiscount = false;
  bool hasExcessPaid = false;
  bool _isAddingItem = false;

  @override
  void dispose() {
    _draft.dispose();
    discountController.dispose();
    paidController.dispose();
    noteController.dispose();
    super.dispose();
  }

  bool _addDraftToList() {
    final name = _draft.nameController.text.trim();
    final quantity = parseBengaliNumber(_draft.quantityController.text) ?? 0;
    final unitPrice = parseBengaliNumber(_draft.priceController.text) ?? 0;
    if (name.isEmpty ||
        !quantity.isFinite ||
        quantity <= 0 ||
        !unitPrice.isFinite ||
        unitPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('পণ্যের নাম, পরিমাণ ও সঠিক দর লিখুন।')),
      );
      return false;
    }
    setState(() {
      _items.add(
        SaleItem(
          name: name,
          quantity: quantity,
          unit: _draft.unit,
          unitPrice: unitPrice,
          price: quantity * unitPrice,
        ),
      );
      _draft.dispose();
      _draft = SellItemRowData();
    });
    _calculateTotal();
    return true;
  }

  void _discardDraft() {
    _draft.dispose();
    setState(() => _draft = SellItemRowData());
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
    _calculateTotal();
  }

  Future<void> _showAddItemDialog(List<Product> products) async {
    setState(() => _isAddingItem = true);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 560,
              maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.88,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return StatefulBuilder(
                  builder: (context, setModalState) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      child: SellItemRow(
                        key: ObjectKey(_draft),
                        itemNumber: _items.length + 1,
                        rowData: _draft,
                        products: products,
                        onRemove: () {
                          _discardDraft();
                          Navigator.pop(dialogContext);
                        },
                        onAddToList: () {
                          final wasAdded = _addDraftToList();
                          if (wasAdded) {
                            Navigator.pop(dialogContext);
                          } else {
                            setModalState(() {});
                          }
                        },
                        onCalculated: () => setModalState(() {}),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
    if (mounted) setState(() => _isAddingItem = false);
  }

  void _calculateTotal() {
    final gross = _items.fold<double>(0, (sum, item) => sum + item.price);

    final enteredDiscount = parseBengaliNumber(discountController.text) ?? 0;
    final validDiscount = enteredDiscount.isFinite ? enteredDiscount : 0;
    final discount = validDiscount.clamp(0.0, gross).toDouble();
    final payable = gross - discount;
    if (isFullPaid) {
      paidController.text = toBengaliDigits(payable.toStringAsFixed(2));
    }
    final enteredPaid = parseBengaliNumber(paidController.text) ?? 0;
    final validPaid = enteredPaid.isFinite ? enteredPaid : 0;
    final paid = validPaid.clamp(0.0, payable).toDouble();

    setState(() {
      grossAmount = gross;
      discountAmount = discount;
      totalAmount = payable;
      paidAmount = paid;
      dueAmount = payable - paid;
      hasExcessDiscount = validDiscount < 0 || validDiscount > gross;
      hasExcessPaid = validPaid < 0 || validPaid > payable;
    });
  }

  void _handleSave() {
    _calculateTotal();
    if (hasExcessDiscount || hasExcessPaid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ছাড় ও জমার পরিমাণ প্রদেয় টাকার মধ্যে রাখুন।'),
        ),
      );
      return;
    }
    if (_items.isEmpty || totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অন্তত একটি পণ্যের সঠিক তথ্য যোগ করুন।')),
      );
      return;
    }

    final transaction = Transaction(
      shopId: '',
      customerId: widget.customer.id,
      type: TransactionType.sell,
      totalAmount: totalAmount,
      discountAmount: discountAmount,
      paidAmount: paidAmount,
      items: _items,
      note: noteController.text.trim().isEmpty
          ? null
          : noteController.text.trim(),
    );

    ref.read(transactionProvider.notifier).addTransaction(transaction);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    final customerDue = ref.watch(customerDueProvider(widget.customer.id));
    final validItems = _items.length;

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _pageBackground,
        foregroundColor: _ink,
        title: const Text(
          'নতুন এন্ট্রি',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: totalAmount > 0 && !hasExcessDiscount && !hasExcessPaid
                ? _handleSave
                : null,
            icon: const Icon(Icons.check_circle_outline_rounded, size: 22),
            label: const Text('বিক্রি সংরক্ষণ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              disabledBackgroundColor: const Color(0xFFB8C4C0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
        children: [
          _CustomerSaleHeader(
            customer: widget.customer,
            customerDue: customerDue,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'পণ্যের তালিকা',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${toBengaliDigits(validItems)}টি পণ্য',
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_items.isNotEmpty) ...[
            ..._items.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SavedSellItemCard(
                  item: entry.value,
                  onRemove: () => _removeItem(entry.key),
                ),
              );
            }),
            const SizedBox(height: 2),
          ],
          ElevatedButton.icon(
            onPressed: _isAddingItem
                ? null
                : () => _showAddItemDialog(products),
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('আরও পণ্য যোগ করুন'),
            style: ElevatedButton.styleFrom(
              elevation: .1,
              foregroundColor: _green,
              backgroundColor: Colors.white,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SellSummary(
            grossAmount: grossAmount,
            discountAmount: discountAmount,
            hasExcessDiscount: hasExcessDiscount,
            hasExcessPaid: hasExcessPaid,
            totalAmount: totalAmount,
            dueAmount: dueAmount,
            customerDue: customerDue,
            itemCount: validItems,
            isFullPaid: isFullPaid,
            discountController: discountController,
            paidController: paidController,
            noteController: noteController,
            onDiscountChanged: _calculateTotal,
            onPaidChanged: _calculateTotal,
            onClearPaid: () {
              isFullPaid = false;
              paidController.text = '০';
              _calculateTotal();
            },
            onNoteChanged: () => setState(() {}),
            onFullPaidChanged: (value) {
              isFullPaid = value;
              if (!isFullPaid) paidController.text = '০';
              _calculateTotal();
            },
          ),
        ],
      ),
    );
  }
}

class _CustomerSaleHeader extends StatelessWidget {
  final Customer customer;
  final double customerDue;

  const _CustomerSaleHeader({
    required this.customer,
    required this.customerDue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [appShadow],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: const Color(0xFFDDF3EB),
                child: Text(
                  customer.name.trim().isEmpty
                      ? '?'
                      : customer.name.trim()[0].toUpperCase(),
                  style: const TextStyle(
                    color: _green,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
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
                        color: _ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'মোবাইল: ${toBengaliDigits(customer.phone)}',
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'বর্তমান বাকি',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currencyFormat.format(customerDue > 0 ? customerDue : 0),
                      style: const TextStyle(
                        color: Color(0xFFB20E42),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  color: _green,
                  size: 19,
                ),
                const SizedBox(width: 7),
                const Text(
                  'বিক্রির এন্ট্রি',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_today_outlined, color: _muted, size: 15),
                const SizedBox(width: 5),
                Text(
                  formatBengaliDate(DateTime.now(), includeTime: false),
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
