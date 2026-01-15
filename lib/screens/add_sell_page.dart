import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../main.dart';

class AddSellPage extends ConsumerStatefulWidget {
  final Customer customer;
  const AddSellPage({super.key, required this.customer});

  @override
  ConsumerState<AddSellPage> createState() => _AddSellPageState();
}

class _AddSellPageState extends ConsumerState<AddSellPage> {
  final List<SaleItem> _items = [SaleItem(name: '', price: 0)];
  final TextEditingController _paidController = TextEditingController(
    text: '0',
  );

  double get _totalAmount => _items.fold(0, (sum, item) => sum + item.price);
  double get _paidAmount => double.tryParse(_paidController.text) ?? 0;
  double get _dueAmount => _totalAmount - _paidAmount;

  @override
  Widget build(BuildContext context) {
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
            ...List.generate(_items.length, (index) => _buildItemRow(index)),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _items.add(SaleItem(name: '', price: 0));
                });
              },
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

  Widget _buildItemRow(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Item name',
                isDense: true,
                border: UnderlineInputBorder(),
              ),
              onChanged: (val) => _items[index] = SaleItem(
                name: val,
                price: _items[index].price,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Price',
                prefixText: '৳ ',
                isDense: true,
                border: UnderlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                setState(() {
                  _items[index] = SaleItem(
                    name: _items[index].name,
                    price: double.tryParse(val) ?? 0,
                  );
                });
              },
            ),
          ),
          if (_items.length > 1)
            IconButton(
              onPressed: () {
                setState(() => _items.removeAt(index));
              },
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

    final transaction = Transaction(
      customerId: widget.customer.id,
      type: TransactionType.sell,
      items: _items.where((i) => i.name.isNotEmpty || i.price > 0).toList(),
      totalAmount: _totalAmount,
      paidAmount: _paidAmount,
    );

    ref.read(transactionProvider.notifier).addTransaction(transaction);
    Navigator.pop(context);
  }
}
