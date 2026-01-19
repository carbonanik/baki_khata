import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../../domain/entities/customer.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/entities/product.dart';
import '../../main.dart';

class AddSellPage extends ConsumerStatefulWidget {
  final Customer customer;
  const AddSellPage({super.key, required this.customer});

  @override
  ConsumerState<AddSellPage> createState() => _AddSellPageState();
}

class _AddSellPageState extends ConsumerState<AddSellPage> {
  final List<_ItemRowData> _rowData = [];
  final TextEditingController _paidController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addNewItem();
  }

  @override
  void dispose() {
    for (var data in _rowData) {
      data.dispose();
    }
    _paidController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addNewItem() {
    _rowData.add(_ItemRowData());
    setState(() {});
  }

  void _removeItem(int index) {
    final removed = _rowData.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  double get _totalAmount {
    return _rowData.fold(0, (sum, item) {
      final price = double.tryParse(item.priceController.text) ?? 0;
      return sum + price;
    });
  }

  double get _paidAmount => double.tryParse(_paidController.text) ?? 0;
  double get _dueAmount => _totalAmount - _paidAmount;

  @override
  Widget build(BuildContext context) {
    // Watch products for autocomplete
    final products = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Sell')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: _saveSell,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'SAVE SELL',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              _rowData.length,
              (index) => _buildItemRow(index, products),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _addNewItem,
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                'ADD ITEM',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(color: Color(0xFFF0F0F0)),
            ),
            _summaryRow('Total Amount', _totalAmount, isBold: true),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Paid Amount',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _paidController,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: '৳ ',
                      isDense: true,
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Add a note (optional)',
                isDense: true,
                border: UnderlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            _summaryRow(
              'Due Amount',
              _dueAmount,
              color: _dueAmount > 0 ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(int index, List<Product> products) {
    final data = _rowData[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: RawAutocomplete<Product>(
              textEditingController: data.nameController,
              focusNode: data.focusNode,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<Product>.empty();
                }
                return products.where((Product option) {
                  return option.name.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              displayStringForOption: (Product option) => option.name,
              onSelected: (Product selection) {
                data.priceController.text = selection.price.toStringAsFixed(
                  0,
                ); // No decimals usually
                setState(() {});
              },
              fieldViewBuilder:
                  (
                    BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Item name',
                        isDense: true,
                        border: UnderlineInputBorder(),
                      ),
                    );
                  },
              optionsViewBuilder:
                  (
                    BuildContext context,
                    AutocompleteOnSelected<Product> onSelected,
                    Iterable<Product> options,
                  ) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: SizedBox(
                          width: 200,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Product option = options.elementAt(index);
                              return InkWell(
                                onTap: () => onSelected(option),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(option.name),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: TextField(
              controller: data.priceController,
              decoration: const InputDecoration(
                hintText: 'Price',
                prefixText: '৳ ',
                isDense: true,
                border: UnderlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_rowData.length > 1)
            IconButton(
              onPressed: () => _removeItem(index),
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Colors.grey,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? Colors.black : Colors.grey,
          ),
        ),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: FontWeight.w800,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  void _saveSell() {
    if (_totalAmount <= 0) return;

    final items = _rowData
        .map((data) {
          final name = data.nameController.text;
          final price = double.tryParse(data.priceController.text) ?? 0;
          return SaleItem(name: name, price: price);
        })
        .where((i) => i.name.isNotEmpty || i.price > 0)
        .toList();

    if (items.isEmpty) return;

    final transaction = Transaction(
      customerId: widget.customer.id,
      type: TransactionType.sell,
      items: items,
      totalAmount: _totalAmount,
      paidAmount: _paidAmount,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    ref.read(transactionProvider.notifier).addTransaction(transaction);
    Navigator.pop(context);
  }
}

class _ItemRowData {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    focusNode.dispose();
  }
}
