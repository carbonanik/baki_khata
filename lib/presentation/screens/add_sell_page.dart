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
    final paid = double.tryParse(paidController.text) ?? 0;

    setState(() {
      totalAmount = total;
      paidAmount = paid;
      dueAmount = total - paid;
    });
  }

  void _handleSave() {
    _calculateTotal(); // Ensure values are up to date
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
          shopId: '', // Provider will set this
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
      appBar: AppBar(title: const Text('New Sale')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ..._rowData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final row = entry.value;
                    return SellItemRow(
                      index: index,
                      rowData: row,
                      products: products,
                      onRemove: () => _removeRow(index),
                      onCalculated: _calculateTotal,
                    );
                  }),
                  TextButton.icon(
                    onPressed: _addNewRow,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                  ),
                  const Divider(height: 32),
                  SellSummary(
                    totalAmount: totalAmount,
                    paidAmount: paidAmount,
                    dueAmount: dueAmount,
                    paidController: paidController,
                    noteController: noteController,
                    onPaidChanged: _calculateTotal,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'SAVE SALE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
