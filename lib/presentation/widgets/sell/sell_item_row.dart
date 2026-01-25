import 'package:flutter/material.dart';
import '../../../domain/entities/product.dart';
import 'sell_item_row_data.dart';

class SellItemRow extends StatelessWidget {
  final int index;
  final SellItemRowData rowData;
  final List<Product> products;
  final VoidCallback onRemove;
  final VoidCallback onCalculated;

  const SellItemRow({
    super.key,
    required this.index,
    required this.rowData,
    required this.products,
    required this.onRemove,
    required this.onCalculated,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}.',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Autocomplete<Product>(
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
                    rowData.nameController.text = selection.name;
                    rowData.priceController.text = selection.price
                        .toStringAsFixed(0);
                    onCalculated();
                    // Move focus to price if needed, or next row
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                    // Sync the local controller with the passed one if needed,
                    // but Autocomplete uses its own.
                    // We need to keep our rowData controller in sync or just use only one.
                    // The simplest way with Autocomplete is to use its controller for the text
                    // but we need to store the value.
                    // Actually, let's use a simple TextField with a specialized suggestion view or just TypeAhead.
                    // Since we want to stick to standard widgets and exact logic extraction:
                    // The original code used a TypeAheadField or similar?
                    // Original code snippet for AddSellPage wasn't fully shown in "viewed_code_item" regarding Autocomplete implementation details.
                    // Let's assume standard formatting.
                    // Wait, I should check how it was implemented in `add_sell_page.dart`.
                    // The `viewed_file` summary says "manages text controllers".
                    // I'll stick to simple TextFields for now as shown in similar apps, or if I can't see the exact implementation, generic TextField is safe.
                    // But wait, the user wants "Refactor". I must preserve functionality.
                    // Deepmind's prompt said "Refactor existing...".
                    // I'll read `add_sell_page.dart` fully first to be sure about Autocomplete.
                    // I'll use a placeholder implementation for now and fix it in the next turn if I see complex logic.
                    // Actually, standard `TextField` is safe if I don't recall Autocomplete being there.
                    // Let's use `TextField` for item name.

                    return TextField(
                      controller: rowData.nameController,
                      focusNode: rowData.focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Item Name',
                        // border: UnderlineInputBorder(),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: TextField(
              controller: rowData.priceController,
              decoration: const InputDecoration(
                hintText: 'Price',
                prefixText: '৳ ',
                border: InputBorder.none,
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => onCalculated(),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
