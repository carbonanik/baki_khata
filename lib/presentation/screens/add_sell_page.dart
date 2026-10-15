import 'package:baki_khata/presentation/widgets/sell/sell_item_row_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/transaction.dart';
import '../widgets/sell/sell_item_row.dart';
import '../widgets/sell/sell_summary.dart';

class AddSellPage extends ConsumerStatefulWidget {
  final Customer customer;
  const AddSellPage({super.key, required this.customer});

  @override
  ConsumerState<AddSellPage> createState() => _AddSellPageState();
}

class _AddSellPageState extends ConsumerState<AddSellPage> {
  final List<SellItemRowData> _rowData = [];
  final paidController = TextEditingController();
  final noteController = TextEditingController();
  double totalAmount = 0;
  double paidAmount = 0;
  double dueAmount = 0;
  bool isFullPaid = false;

  @override
  void initState() {
    super.initState();
    _addNewRow();
  }

  @override
  void dispose() {
    for (var row in _rowData) {
      row.dispose();
    }
    paidController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _addNewRow() {
    setState(() {
      _rowData.add(SellItemRowData());
    });
  }

  void _removeRow(int index) {
    if (_rowData.length > 1) {
      setState(() {
        _rowData[index].dispose();
        _rowData.removeAt(index);
        _calculateTotal();
      });
    }
  }

  void _calculateTotal() {
    double total = 0;
    for (var row in _rowData) {
      final price = double.tryParse(row.priceController.text) ?? 0;
      total += price;
    }

    if (isFullPaid) {
      paidController.text = total.toStringAsFixed(0);
    }

    final paid = double.tryParse(paidController.text) ?? 0;

    setState(() {
      totalAmount = total;
      paidAmount = paid;
      dueAmount = total - paid;
    });
  }

  void _handleSave() {
    _calculateTotal();
    if (totalAmount > 0) {
      final items = _rowData
          .where(
            (row) =>
                row.nameController.text.isNotEmpty &&
                (double.tryParse(row.priceController.text) ?? 0) > 0,
          )
          .map(
            (row) => SaleItem(
              name: row.nameController.text,
              price: double.tryParse(row.priceController.text) ?? 0,
            ),
          )
          .toList();

      if (items.isNotEmpty) {
        final transaction = Transaction(
          shopId: '',
          customerId: widget.customer.id,
          type: TransactionType.sell,
          totalAmount: totalAmount,
          paidAmount: paidAmount,
          items: items,
          note: noteController.text.trim().isEmpty
              ? null
              : noteController.text.trim(),
        );

        ref.read(transactionProvider.notifier).addTransaction(transaction);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE2ECFF),
              child: Text(
                widget.customer.name.trim().isEmpty
                    ? '?'
                    : widget.customer.name.trim()[0].toUpperCase(),
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
                    widget.customer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    widget.customer.phone,
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
      body: SafeArea(
        child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF9EACC2,
                            ).withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Items',
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _addNewRow,
                                  icon: const Icon(Icons.add, size: 20),
                                  label: const Text('Add Item'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF1557D5),
                                    backgroundColor: const Color(0xFFF0F5FF),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 9,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFF0F2F5)),
                          const SizedBox(height: 12),
                          ..._rowData.asMap().entries.map((entry) {
                            final index = entry.key;
                            final row = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: SellItemRow(
                                index: index,
                                rowData: row,
                                products: products,
                                onRemove: () => _removeRow(index),
                                onCalculated: _calculateTotal,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SellSummary(
                      totalAmount: totalAmount,
                      dueAmount: dueAmount,
                      itemCount: _rowData
                          .where((row) => row.nameController.text.trim().isNotEmpty)
                          .length,
                      isFullPaid: isFullPaid,
                      paidController: paidController,
                      noteController: noteController,
                      onPaidChanged: _calculateTotal,
                      onClearPaid: () {
                        isFullPaid = false;
                        paidController.text = '0';
                        _calculateTotal();
                      },
                      onNoteChanged: () => setState(() {}),
                      onFullPaidChanged: (val) {
                        isFullPaid = val;
                        if (!isFullPaid) {
                          paidController.text = '0';
                        }
                        _calculateTotal();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: totalAmount > 0 ? _handleSave : null,
                    icon: const Icon(Icons.receipt_long_outlined, size: 20),
                    label: const Text('SAVE SELL'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111315),
                      disabledBackgroundColor: const Color(0xFF9CA3AF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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
