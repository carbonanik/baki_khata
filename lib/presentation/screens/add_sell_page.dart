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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.customer.name,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: totalAmount > 0 ? _handleSave : null,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: totalAmount > 0 ? Colors.black87 : Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Thin divider
          Container(height: 1, color: Colors.grey[200]),

          Expanded(
            child: SingleChildScrollView(
              // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Items Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          'Items',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        ..._rowData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final row = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SellItemRow(
                              index: index,
                              rowData: row,
                              products: products,
                              onRemove: () => _removeRow(index),
                              onCalculated: _calculateTotal,
                            ),
                          );
                        }),

                        // Add Item Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _addNewRow,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 20, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Add Item',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(),
                  const SizedBox(height: 32),

                  // Summary Section
                  SellSummary(
                    totalAmount: totalAmount,
                    paidAmount: paidAmount,
                    dueAmount: dueAmount,
                    isFullPaid: isFullPaid,
                    paidController: paidController,
                    noteController: noteController,
                    onPaidChanged: _calculateTotal,
                    onFullPaidChanged: (val) {
                      setState(() {
                        isFullPaid = val;
                        // Clear paid amount if not full paid
                        if (!isFullPaid) {
                          paidController.text = '0';
                        }
                        _calculateTotal();
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
