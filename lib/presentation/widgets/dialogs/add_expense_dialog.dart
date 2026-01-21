import 'package:baki_khata/domain/entities/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';

class AddExpenseDialog extends ConsumerStatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final categoryController =
      TextEditingController(); // For custom category if needed
  String selectedCategory = 'Rent'; // Default

  final List<String> categories = [
    'Rent',
    'Electricity',
    'Broadband',
    'Staff Salary',
    'Tea/Snacks',
    'Transport',
    'Other',
  ];

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Expense'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: UnderlineInputBorder(),
              ),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => selectedCategory = val);
              },
            ),
            if (selectedCategory == 'Other')
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Custom Category Name',
                  border: UnderlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (৳)',
                border: UnderlineInputBorder(),
                prefixText: '৳ ',
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                border: UnderlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: _saveExpense,
          child: const Text(
            'ADD',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _saveExpense() {
    final amount = double.tryParse(amountController.text);
    if (amount != null && amount > 0) {
      final category =
          selectedCategory == 'Other' && categoryController.text.isNotEmpty
          ? categoryController.text
          : selectedCategory;

      final expense = Expense(
        shopId: '', // Provider handles this
        amount: amount,
        category: category,
        note: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
      );

      ref.read(expenseProvider.notifier).addExpense(expense);
      Navigator.pop(context);
    }
  }
}
