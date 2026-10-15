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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF1F5),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Color(0xFF343B46),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Autocomplete<Product>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Product>.empty();
                    }
                    return products.where(
                      (product) => product.name.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                    );
                  },
                  displayStringForOption: (product) => product.name,
                  onSelected: (selection) {
                    rowData.nameController.text = selection.name;
                    rowData.priceController.text = selection.price
                        .toStringAsFixed(0);
                    onCalculated();
                  },
                  fieldViewBuilder:
                      (context, textEditingController, focusNode, onSubmitted) {
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onChanged: (value) {
                            rowData.nameController.text = value;
                            onCalculated();
                          },
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Item name',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9AA3B0),
                              fontSize: 15,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 5,
                            ),
                            border: InputBorder.none,
                            suffixIcon: textEditingController.text.isNotEmpty
                                ? null
                                : const Icon(
                                    Icons.search,
                                    size: 18,
                                    color: Color(0xFF9AA3B0),
                                  ),
                          ),
                        );
                      },
                ),
                const SizedBox(height: 7),
                SizedBox(
                  width: 145,
                  child: TextField(
                    controller: rowData.priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => onCalculated(),
                    style: const TextStyle(
                      color: Color(0xFF586273),
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      prefixText: '৳ ',
                      hintText: 'Price',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9AA3B0),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE5E9EF)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF9AB9F3)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFE35A5A),
              size: 21,
            ),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFFEEEE),
              minimumSize: const Size(38, 38),
              padding: EdgeInsets.zero,
            ),
            tooltip: 'Remove item',
          ),
        ],
      ),
    );
  }
}
